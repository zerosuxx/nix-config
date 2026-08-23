#!/system/bin/sh

set -eu

STORE_PATH="/nix/store/dvf2ck9bkw7yyrlkjk87xz1anaxsgrd6-proot-termux-static-aarch64-unknown-linux-android-unstable-2026-02-20"
TARGET="/data/data/com.termux.nix/files/usr/bin/.proot-static.new"

nix-store --realise "$STORE_PATH"

cp "$STORE_PATH/bin/proot-static" "$TARGET"
chmod +x "$TARGET"

echo "Patched proot installed:"
sha256sum "$TARGET"
