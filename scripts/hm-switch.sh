#!/usr/bin/env sh

target="$1"

nix run .#home-manager -- switch --flake .#$target