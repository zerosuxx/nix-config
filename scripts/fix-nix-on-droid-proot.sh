#!/system/bin/sh

set -eu

# Shared release pin with the Nix-on-Droid activation step.
CONFIG_DIR="$(dirname "$0")/../nix-on-droid"
URL="$(cat "$CONFIG_DIR/proot-static-url")"
EXPECTED_HASH="$(cat "$CONFIG_DIR/proot-static-sha256")"
TARGET="/data/data/com.termux.nix/files/usr/bin/.proot-static.new"

# Download beside the target so the final rename is atomic. Keep any previous
# staged binary intact if the download or checksum verification fails.
TEMP_FILE="$(mktemp "${TARGET}.XXXXXX")"
trap 'rm -f "$TEMP_FILE"' EXIT
trap 'exit 1' HUP INT TERM
curl --fail --location --retry 3 --output "$TEMP_FILE" "$URL"
printf '%s  %s\n' "$EXPECTED_HASH" "$TEMP_FILE" | sha256sum -c -
chmod 700 "$TEMP_FILE"
mv "$TEMP_FILE" "$TARGET"

echo "Patched proot staged; restart Nix-on-Droid completely to activate it:"
sha256sum "$TARGET"
