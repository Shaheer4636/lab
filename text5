#!/bin/bash

##############################################################################
# Basic environment setup:
#    to be done before running any batch or online programs
#
# Following environment variables are expected to be set:
#    JAVA_HOME: home location of java, $JAVA_HOME/bin/java expected
#    DB_BACKUP_RESTORE_TOOLS_HOME: home of backup/restore tools
#    DB_ADMIN_USER: for backup/restore
#    DB_ADMIN_PASSWORD: for backup/restore
##############################################################################

# Environment settings
export JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
export DB_BACKUP_RESTORE_TOOLS_HOME="/usr/pgsql-12/bin"
export DB_ADMIN_USER="postgres"
export DB_ADMIN_PASSWORD="ctYaiBWhmD950gBOindo"

# Base locations
RUN_DIR="$(dirname "$(readlink -f "$0")")/.."
export RUN_DIR

# Derived directories
export TEMP_DIR="$RUN_DIR/temp-files"
export LOG_DIR="$RUN_DIR/log-files"
export LOG_FILE="$LOG_DIR/videorental.log"
export IBM_FILE_ROOT="$RUN_DIR/data-files"
export IBM_SYSOUT_FILE_DIR="$RUN_DIR/sysout-files"
export IBM_SYSOUT_FILE_NAME_PATTERN="%m/%j.%s.%l.%d-%t.%o"
export IBM_TEMP_DIR_ROOT="$RUN_DIR/temp-files"

# Framework settings
export ABX_SOURCE_PLATFORM="ZOS"
export ZOS_DECLARATIONS="$RUN_DIR/framework/bash/zos_declarations"

# Application settings
export APP_DB_HOST="localhost"
export APP_DB_PORT=5432
export APP_DB_NAME="videorental"
export APP_DB_JDBC_URL="jdbc:postgresql://prd-pgsql-1:5432/videorental"
export APP_DB_USER="demo"
export APP_DB_SECRET="oDstXzSSUoWYOYXFzXBXRfgX"
export FRMWK_DB_JDBC_URL="$APP_DB_JDBC_URL"
export FRMWK_DB_USER="$APP_DB_USER"
export FRMWK_DB_SECRET="$APP_DB_SECRET"

# CICS Region settings
export CICS_SYSID="ANBX"

# Redis Settings
export REDIS_HOST="localhost"
export REDIS_PORT=6379

# Process Management Settings
export PMS_HOST="localhost"
export PMS_PORT=8010

# Recovery Service Settings
export RECOVERY_HOST="localhost"
export RECOVERY_PORT=1020

# Presentation Service Settings
export PS_PORT=8001
export PS_HTTP_PORT=8002
export PS_3270_PORT=8003

# Main XML config file
export ZOS_SERVICES_CONFIG="$RUN_DIR/config-files/application.config"
export ZOS_STATE="$RUN_DIR/config-files/online-state.xml"

# CLASSPATH settings
CLASSPATH=""
for JAR in "$RUN_DIR/libraries"/*.jar; do
  CLASSPATH="$CLASSPATH:$JAR"
done
export CLASSPATH

# COBOL Program Search Path
export ABX_COBOL_PROGRAM_SEARCH_PATH="$RUN_DIR/libraries/demo.videorental.programs.jar:$RUN_DIR/libraries/demo.videorental.integration.jar"

# Debugging and Profiling Options
export DEBUG_PORT=8887
export DEBUG_BATCH_UTIL=""
export DEBUG_BATCH_PROGRAM=""
export DEBUG_ONLINE=""

export ABX_BATCH_PROGRAM_CMD="$JAVA_HOME/bin/java -cp \"$CLASSPATH\" $DEBUG_BATCH_PROGRAM com.demo.videorental.drivers.BatchDriver --config-file=$ZOS_SERVICES_CONFIG run"

# Process Management
export PROCESS_MANAGEMENT_SERVICE_DIR="$RUN_DIR/pms"
export PRESENTATION_SERVICE_DIR="$RUN_DIR/ps"
export JRE_EXEC="$JAVA_HOME/bin/java"
export JVM_DLL="$JAVA_HOME/lib/server/libjvm.so"

# System Info
export ZOS_JOB_START_TIME=$(date +"%Y%m%d_%H%M%S")
export ZOS_JOB_PID=$$
export ZOS_TEMP_DIR="$TEMP_DIR"
export ZOS_SPOOL_DIR="$TEMP_DIR"

exit 0
