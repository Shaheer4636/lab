echo "starting $(T_NAME)"

# Bind ADO vars to shell vars (ADO substitutes the right side before sending)
TARGET_BSRO_DIR='$(TARGET_BSRO_DIR)'
BACKUP_BSRO_PATH='$(BACKUP_BSRO_PATH)'
RELEASE_NAME='$(Release.ReleaseName)'

# Sanity check
echo "SOURCE: $TARGET_BSRO_DIR"
echo "DEST:   ${BACKUP_BSRO_PATH}-${RELEASE_NAME}/bsro/"

# Ensure source exists (fail fast with a clear message)
if [ ! -d "$TARGET_BSRO_DIR" ]; then
  echo "ERROR: source directory not found: $TARGET_BSRO_DIR"
  exit 1
fi

sudo mkdir -p "${BACKUP_BSRO_PATH}-${RELEASE_NAME}/bsro"

# Copy everything (including dotfiles), preserving perms/ownerships
sudo cp -a "$TARGET_BSRO_DIR/." "${BACKUP_BSRO_PATH}-${RELEASE_NAME}/bsro/" || true
