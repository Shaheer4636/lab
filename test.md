Great — to **replicate this project folder structure** (shown in the image) under your shared directory `/srv/shared`, you can do it with just a few commands.

---

### ✅ Step-by-Step: Replicate Folder Structure in `/srv/shared/BatchAppRunTime`

1. Run the following commands:

```bash
sudo mkdir -p /srv/shared/BatchAppRunTime/{run/{batch-scripts/{proclib1,proclib2,etc},bin/{bash/zos_declarations},config,data-files,log-files/{where/b,y,etc},temp-files},helm/templates,scripts,tbd}
```

2. Create placeholder files (optional but helpful):

```bash
sudo touch /srv/shared/BatchAppRunTime/{Dockerfile,entrypoint.sh}
sudo touch /srv/shared/BatchAppRunTime/run/config/{application.config,setenv.sh}
sudo touch /srv/shared/BatchAppRunTime/helm/{Chart.yaml,chart.yaml,values.yaml}
sudo touch /srv/shared/BatchAppRunTime/helm/templates/{job.yaml,configmap.yaml,secret.yaml,serviceaccount.yaml}
```

---

### ✅ Set Correct Ownership and Permissions

If you're using the shared group setup (`sharedgroup`), do this:

```bash
sudo chown -R root:sharedgroup /srv/shared/BatchAppRunTime
sudo chmod -R 2775 /srv/shared/BatchAppRunTime
sudo find /srv/shared/BatchAppRunTime -type d -exec chmod g+s {} \;
```

---

### ✅ Result

Your directory structure under `/srv/shared/BatchAppRunTime` will now match the one in your image, fully accessible and writable by all users in the `sharedgroup`.

Let me know if you also want:

* Git initialized here
* Helm/K8s config adapted
* A sample script or README inside this structure
