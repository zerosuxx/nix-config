#!/usr/bin/env sh
# First Home Manager switch on a fresh single-user Nix install.
#
# The installer puts its own nix (and cacert) into the profile with nix-env,
# while packages/linux.nix brings nix too, so the first switch fails with a
# profile conflict. Lower the priority of every package installed so far so
# home-manager wins; nix stays on PATH for the switch itself.
#
# Usage: sh scripts/init-hm.sh [flake-ref]   (default: ".", i.e. $USER@$HOSTNAME)
set -eu

cd "$(dirname "$0")/.."

for pkg in $(nix-env -q); do
  case "$pkg" in
    home-manager-path)
      echo "${pkg} package priority update skipped."
      continue
      ;;
  esac
  nix-env --set-flag priority 10 "$pkg"
  echo "${pkg} package priority updated to '10'"
done

export NIX_CONFIG="experimental-features = nix-command flakes"
nix shell nixpkgs#git nixpkgs#openssh --command \
  nix run home-manager -- switch -b backup --impure --flake "${1:-.}"
