runner.sh
This shell script is designed to automate the setup and registration of a GitLab CI runner. It includes necessary environment variables like runner_name, runner_version, and docker_image, and assumes the system has Docker, curl, and cron installed, along with GitLab TLS certificates.

Key points:

The script targets a GitLab instance (gitlab-1.ccg.com).

It registers a runner using a version-specific token.

The runner uses Docker as the executor and is containerized under gitlab-runner.

It sets a script directory dynamically using realpath.

A cron job is written to ensure the runner script executes on boot for resiliency.
