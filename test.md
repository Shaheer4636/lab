Here’s your updated, professional-format notes without any emojis or informal symbols—ready to use in a ticket or formal update:

---

### File 1: `cluster/ci/configs/kube-lint-config.yaml`

This YAML file configures kube-lint to enforce Kubernetes best practices. It enables all built-in checks by default using `addAllBuiltIn: true`, but selectively excludes specific rules like `access-to-secrets`, `exposed-services`, `privileged-ports`, and others that may not apply or are intentionally relaxed for the project. This configuration helps maintain YAML quality, security posture, and policy compliance across manifests.

---

### File 2: `cluster/ci/scripts/run-manual-yamllint.sh`

This shell script automates linting for all YAML files in the repo. It searches for `.yml`, `.yaml`, and `.yamllint*` files and lists them in `yamlsList.txt`. It then runs `yamllint` using the configured policy from `kube-lint-config.yaml` and saves the output to `yamllint.txt`. Finally, it prints out the lint result count for visibility. This is useful for enforcing linting during development or pre-merge checks.

---

### File 3: `cluster/.yamllint-config.yml`

This file defines custom `yamllint` behavior. It extends the default config and specifies ignored paths (like certain charts and CRDs). It applies rule customizations such as:

* Using 2-space indentation
* Disabling line length, truthy checks, and document start markers
* Setting comment level to "warning"

These settings ensure consistent YAML formatting across the codebase, supporting both readability and CI/CD compliance.

