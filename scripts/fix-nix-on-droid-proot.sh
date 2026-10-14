#!/system/bin/sh

set -eu

# Shared with the Nix-on-Droid config, which keeps this proot staged on every switch.
STORE_PATH="$(cat "$(dirname "$0")/../nix-on-droid/proot-static-path")"
TARGET="/data/data/com.termux.nix/files/usr/bin/.proot-static.new"

nix-store --realise "$STORE_PATH"

cp "$STORE_PATH/bin/proot-static" "$TARGET"
chmod +x "$TARGET"

echo "Patched proot installed:"
sha256sum "$TARGET"
