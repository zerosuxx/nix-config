#!/usr/bin/env sh

set -xe

target="$1"
force="$2"

export NIX_CONFIG="experimental-features = nix-command flakes"

options=""
if [ "$force" = "1" ]; then
  options="-b bak-nix"
fi
nix run .#home-manager -- $options switch --impure --flake .#"$target"
