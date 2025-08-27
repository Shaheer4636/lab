set -euo pipefail

# Bind ADO variables
SRC='$(SOURCE_DIR)/'
DST='$(PIPELINE_USER)@$(SERVER_IP):$(TARGET_DIR)/'
KEY_FILE='$(KEY.secureFilePath)'

chmod 600 "$KEY_FILE"

echo "SRC: $SRC"
echo "DST: $DST"

# Use the key via ssh
rsync -rltDv --info=progress2 \
  -e "ssh -i $KEY_FILE -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
  "$SRC" "$DST"
