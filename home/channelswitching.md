Below is a clean, copyable **step-by-step guide** for putting CEQ on a feature-branch workflow using **TeamCity + Octopus**. It matches what you’ve configured and adds the missing pieces so you can test and prove it for the ticket.

---

# Goal

* Branch builds (`CEQ/*`, `feature/*`) → build, create an Octopus **Feature**-channel release, auto-deploy to **DEV**; optionally promote to **STAGING** for approval.
* Master builds → create a **Production**-channel release and follow your **STAGING → PROD** lifecycle.

---

## 1) TeamCity: make branches visible

1. Open **HFM.CEQ → Edit Configuration Settings → Version Control**.
2. Click your **VCS Root** → **Edit**.
3. Set:

   * **Default branch:**

     ```
     refs/heads/master
     ```
   * **Branch specification:**

     ```
     +:refs/heads/master
     +:refs/heads/feature/*
     +:refs/heads/CEQ/*
     ```
4. **Save** → **Test connection**.
5. Back in the build config, open the **Branches** tab and confirm you see `master` plus your `CEQ/us-*` branches.

---

## 2) TeamCity: trigger builds

Use one build configuration and trigger on all branches.

1. **HFM.CEQ → Triggers → Add new trigger → VCS Trigger**.
2. **Branch filter**:

   ```
   +:*
   ```

   Notes:

   * Trigger filters use **logical** names (no `refs/heads/`).
   * If you want to exclude master here and have a separate PROD config, change to:

     ```
     +:CEQ/*
     +:feature/*
     -:master
     ```
3. **Save**.

---

## 3) TeamCity: parameters

You will set the Octopus **channel** and **release version** dynamically at the start of every build.

1. **Parameters → Add new parameter**

   * **Name:** `octo.channel`
   * **Value:** `Feature`  (default; the script below will flip it to `Production` on master)
   * Save.

2. Optional default env parameter (if you also gate steps by env):

   * **Name:** `env.DEPLOY_ENV`
   * **Value:** `DEV`  (the script can set `PROD` on master if you want)

---

## 4) TeamCity: Step 1 sets channel and version

Add this as the **first** build step.

### Windows agents (PowerShell)

```powershell
$branch  = "%teamcity.build.branch%"    # logical name: master, CEQ/us-...
$counter = "%build.counter%"

function Sanitize([string]$s) { $s.ToLower() -replace '[^a-z0-9._-]','-' }

# Channel: Feature for branches, Production for master
$channel = if ($branch -eq "master") { "Production" } else { "Feature" }
Write-Host "##teamcity[setParameter name='octo.channel' value='$channel']"

# Version: plain semver on master; pre-release on branches
if ($branch -eq "master") { $version = "0.0.$counter" }
else { $version = "0.0.$counter-" + (Sanitize $branch) }

Write-Host "##teamcity[setParameter name='env.PACKAGE_VERSION' value='$version']"

# Optional: set env routing for later step conditions
$envTarget = if ($branch -eq "master") { "PROD" } else { "DEV" }
Write-Host "##teamcity[setParameter name='env.DEPLOY_ENV' value='$envTarget']"

Write-Host "Octopus channel: $channel"
Write-Host "Release version: $version"
Write-Host "Deploy env: $envTarget"
```

### Linux agents (Bash)

```bash
BRANCH="%teamcity.build.branch%"
COUNTER="%build.counter%"

sanitize() { echo "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9._-]/-/g'; }

if [ "$BRANCH" = "master" ]; then
  CHANNEL="Production"
  VERSION="0.0.$COUNTER"
  DEPENV="PROD"
else
  CHANNEL="Feature"
  VERSION="0.0.$COUNTER-$(sanitize "$BRANCH")"
  DEPENV="DEV"
fi

echo "##teamcity[setParameter name='octo.channel' value='$CHANNEL']"
echo "##teamcity[setParameter name='env.PACKAGE_VERSION' value='$VERSION']"
echo "##teamcity[setParameter name='env.DEPLOY_ENV' value='$DEPENV']"
echo "Octopus channel: $CHANNEL"
echo "Release version: $VERSION"
echo "Deploy env: $DEPENV"
```

After a run, check the **Parameters** tab:

* Branch build: `octo.channel=Feature`, `env.PACKAGE_VERSION=0.0.<n>-<branch>`, `env.DEPLOY_ENV=DEV`
* Master build: `octo.channel=Production`, `env.PACKAGE_VERSION=0.0.<m>`, `env.DEPLOY_ENV=PROD`

---

## 5) Octopus: channels

You’ve started this; complete as follows.

### Channel: Feature

* **Lifecycle:** your “Autodeploy to DEV”.
* **Package Version Rule** for each package step you release against:

  * **Pre-release tag:** `.+` (regex)
  * This accepts versions with a suffix, for example `0.0.179-test-branch`.

### Channel: Production

* **Lifecycle:** your normal `DEV → STAGING → PROD` with **Manual Intervention** in STAGING.
* **Package Version Rule** for the same package step(s):

  * **Pre-release tag:** `^$` (regex)
  * This accepts versions with **no** suffix, for example `0.0.180`.

Save both channels.

---

## 6) TeamCity → Octopus: create and deploy releases

Use the Octopus plugin steps or the `octo` CLI. Fill fields with the parameters you set.

### Create Release (plugin)

* **Project:** `HFM.CEQ`
* **Channel:** `%octo.channel%`
* **Release number:** `%env.PACKAGE_VERSION%`
* **Package version(s):** `%env.PACKAGE_VERSION%`
  (if multiple packages, map step→version)

### Deploy Release (plugin) — optional

* If your **Feature** channel lifecycle already autodeploys to DEV, you can skip this step.
* If you keep it, add two deploy steps and condition them:

  * DEV step: run only if parameter `env.DEPLOY_ENV` equals `DEV`, Environment = `DEV`
  * PROD / STAGING step(s): run only if `env.DEPLOY_ENV` equals `PROD`, Environment = `STAGING` or `PROD` per your policy

### CLI equivalents

```bash
octo create-release \
  --project "HFM.CEQ" \
  --channel "%octo.channel%" \
  --releaseNumber "%env.PACKAGE_VERSION%" \
  --packageVersion "%env.PACKAGE_VERSION%" \
  --server "%octo.serverUrl%" --apiKey "%octo.apiKey%" --space "%octo.space%"

# optionally:
octo deploy-release \
  --project "HFM.CEQ" \
  --releaseNumber "%env.PACKAGE_VERSION%" \
  --deployTo DEV \
  --server "%octo.serverUrl%" --apiKey "%octo.apiKey%" --space "%octo.space%"
```

---

## 7) Test end-to-end

1. Create a branch `CEQ/test-branch` and push a trivial change.
2. In TeamCity:

   * Build triggers automatically.
   * Parameters show `octo.channel=Feature`, `env.PACKAGE_VERSION` with suffix.
3. In Octopus:

   * New **Feature** channel release appears and auto-deploys to **DEV**.
   * Click **Promote to STAGING** and complete the approval step.
4. Merge a PR to `master`.
5. In TeamCity:

   * New build on master; parameters show `octo.channel=Production`, `env.PACKAGE_VERSION` without suffix.
6. In Octopus:

   * New **Production** channel release follows your STAGING approval then PROD.

---

## 8) What to paste on the ticket as proof

* TeamCity **Branches** tab showing a branch build.
* TeamCity **Parameters** for that build showing `octo.channel=Feature` and `env.PACKAGE_VERSION` with suffix.
* Octopus **Releases** page showing the Feature release deployed to **DEV** and promoted to **STAGING** with approval.
* TeamCity master build parameters showing `octo.channel=Production`, `env.PACKAGE_VERSION` without suffix.
* Octopus **Production** release path through **STAGING → PROD**.

---

## 9) Troubleshooting

* Branch not visible in TeamCity: check VCS Root **Branch specification**; use `refs/heads/...`.
* Build not triggering: check **VCS Trigger** branch filter; `+:*` is simplest.
* Release lands in wrong channel: verify `octo.channel` value, and that the release number has or lacks a pre-release suffix according to the channel rule.
* Octopus rejects release: ensure the **Package Version Rule** is added to the package step actually used to create the release.

---

If you want this as a Markdown file you can share, say the word and I’ll output it in that format exactly as above.
