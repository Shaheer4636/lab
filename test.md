

### File: `blro_main_template.yml`

This is the **primary GitLab CI template** that orchestrates multiple pipeline stages using includes such as:

* `build-infra.yml`
* `deploy-cluster.yml`
* `cluster-scanning.yml`
* `deliver-artifacts.yml`
* `destroy.yml`

The file defines high-level jobs for static analysis, changelog validation, and ansible linting, but most are currently commented out. It’s the backbone of the CI/CD process, meant to modularize and organize complex workflows.

---

### File: `build-infra.yml`

This file contains the **infrastructure provisioning logic**. It:

* Initializes Terraform
* Uses SSH to communicate with a VM
* Sets up SSH keys with `sshpass` and `ssh-copy-id`
* Pulls output from Terraform to dynamically extract the controller IP

It's executed during the `build-infra` stage and sets the foundation for further configuration management or deployment steps.

---

### File: `cluster-scanning.yml`

Handles **security compliance scanning** using `kube-bench` against the CIS Kubernetes benchmark.
It:

* SSHs into a target node
* Downloads and installs `kube-bench`
* Runs the benchmark for CIS level 1
* Copies back the resulting `cis_compliance_report.yaml`

This ensures the deployed cluster is scanned for misconfigurations.

---

### File: `deliver-artifacts.yml`

This template supports **artifact packaging and delivery** to GitLab's package registry.
It includes two jobs:

* `.push-package`: uploads application tarballs using curl and `$CI_JOB_TOKEN`
* `.docs-deliver-package`: uploads documentation zip files

Also uses `apk add curl` in `before_script` and prints GitLab CI environment variables for debugging.

---

### File: `deploy-cluster.yml`

Orchestrates the **deployment of a Kubernetes cluster**, running tasks like:

* Copying tarballs for Bloodrock config and tests
* Unpacking and modifying integration config files
* Injecting PSS policies and exemptions
* Running a deployment via `prod-k8sctl.sh`

It supports both single-node and multi-node deployment variants with IP extraction from Terraform output.

---

### File: `destroy.yml`

Manages **tear-down operations** for both cluster and infrastructure:

* `.destroy-cluster`: SSH into the VM and run `prod-k8sctl.sh prod_down`
* `.destroy-infra`: Clones the infra repo, initializes Terraform, and destroys resources using `terraform destroy -auto-approve`

Also sends a DELETE request to remove remote state metadata from GitLab-hosted infra state backend.

---

### File: `functional-testing.yml`

Includes jobs like:

* `fluentd-tests`
* `kyverno-tests`

These jobs:

* SSH into the integration test VM
* Set the Go binary path
* Run `go test` against specified test files (`fluentd_test.go`, `kyverno_test.go`)





### File: `package-artifacts.yml`

This file manages multiple packaging-related jobs in the CI/CD pipeline:

* `.build-dev-image`: Builds and pushes an Ansible Docker image using `pkg-tool.sh`.
* `.build-smoke-test-image`: Builds a test image using a smoke test Dockerfile, though marked as non-functional (`TODO` comment).
* `.package-bloodrock`: Sets up `docker:dind` with insecure registries for internal usage. It also sets up SSH keys and logs into Docker for Ansible-related builds.
* `.package-functional-tests`: Runs `go test` against helper functions, tars results, and stores as artifacts.
* `.docs-pandoc-build`: Converts Markdown and PDF documentation using `pandoc` and `python3`, then saves artifacts for documentation.
* `.docs-pull-kubernetes-docs`: Downloads Kubernetes and Helm documentation zip from Nexus and extracts it.

This file is essential for Docker image packaging, test image building, and preparing documentation artifacts.

---

### File: `static-analysis.yml`

This pipeline YAML focuses on enforcing quality gates and standards:

* `.enforce-changelog-edit`: Ensures the changelog has entries for new tags.
* `.lint-ansible`: SSH key setup, Python virtualenv activation, and Ansible linting via `make lint`.
* `.kube-linter`: Downloads and runs `kube-linter` against Kubernetes manifests using a custom kube-lint config.
* `.bad-word-scanner`: Runs a Python script (`bad_word_scanner.py`) to scan for disallowed words.
* `.lint-yaml`: Runs `yamllint` across all YAML files using a generated list (`yamlsList.txt`), ensuring compliance with formatting rules.
* `.docs-markdown-spellcheck`: Uses `mdspell` to perform spell checks on documentation files.
* `.docs-markdown-lint`: Lints markdown files for formatting and style compliance using `mdl`.
* `.trivy-container-scan`: Runs a Trivy scan against Docker containers in the CI registry.



