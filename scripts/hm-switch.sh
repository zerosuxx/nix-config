#!/usr/bin/env sh

target="$1"

#cd $(realpath $(dirname $(dirname "${BASH_SOURCE[0]}")))
export NIX_CONFIG="experimental-features = nix-command flakes"
nix run .#home-manager -- switch --impure --flake .#$target