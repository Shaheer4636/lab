set -euo pipefail

SRC="$(SOURCE_DIR)/"
DST="$(PIPELINE_USER)@$(SERVER_IP):$(TARGET_DIR)/"
KEY_FILE="$(KEY.secureFilePath)"

chmod 600 "$KEY_FILE"

# Optional: show paths
echo "SRC: $SRC"
echo "DST: $DST"

# Copy; disable host key checking for first-time connects
rsync -rltDv --info=progress2 \
  -e "ssh -i $KEY_FILE -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
  "$SRC" "$DST"
