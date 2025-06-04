mkdir -p BatchAppRunTime/{run/{batch-scripts/{proclib1,proclib2,etc},bin/bash/zos_declarations,config,data-files,log-files/{b,y,etc},temp-files},helm/templates,scripts,tbd}

touch BatchAppRunTime/{Dockerfile,entrypoint.sh,README.md}
touch BatchAppRunTime/run/config/{application.config,setenv.sh}
touch BatchAppRunTime/helm/{Chart.yaml,values.yaml}
touch BatchAppRunTime/helm/templates/{job.yaml,configmap.yaml,secret.yaml,serviceaccount.yaml}
