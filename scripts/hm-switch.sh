#!/usr/bin/env sh

target="$1"

#cd $(realpath $(dirname $(dirname "${BASH_SOURCE[0]}")))

nix run .#home-manager -- switch --impure --flake .#$target