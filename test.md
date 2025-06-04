# Create main folders
mkdir -p BatchAppRunTime/{run/{batch-scripts/{proclib1,proclib2,etc},bin/bash,config,data-files,log-files/{b,y,etc},temp-files},helm/templates,scripts,tbd}

# Create files
touch BatchAppRunTime/{Dockerfile,entrypoint.sh,README.md}

# Create config files
touch BatchAppRunTime/run/config/{application.config,setenv.sh}

# Create .jar directory and zos_declarations
mkdir -p BatchAppRunTime/run/bin/zos_declarations

# Create helm files
touch BatchAppRunTime/helm/{Chart.yaml,values.yaml}
touch BatchAppRunTime/helm/templates/{job.yaml,configmap.yaml,secret.yaml,serviceaccount.yaml}
