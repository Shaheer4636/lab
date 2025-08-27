echo "starting $(T_NAME)"; \
TARGET_BSRO_DIR='$(TARGET_BSRO_DIR)'; BACKUP_BSRO_PATH='$(BACKUP_BSRO_PATH)'; RELEASE_NAME='$(Release.ReleaseName)'; \
echo "SOURCE: $TARGET_BSRO_DIR"; \
echo "DEST:   ${BACKUP_BSRO_PATH}-${RELEASE_NAME}/bsro/"; \
[ -d "$TARGET_BSRO_DIR" ] || { echo "ERROR: source directory not found: $TARGET_BSRO_DIR"; exit 1; }; \
sudo mkdir -p "${BACKUP_BSRO_PATH}-${RELEASE_NAME}/bsro"; \
sudo cp -a "$TARGET_BSRO_DIR/." "${BACKUP_BSRO_PATH}-${RELEASE_NAME}/bsro/" || true
