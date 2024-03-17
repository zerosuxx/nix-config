#!/usr/bin/env sh

for pkg in $(nix-env -q); do
  if [[ "${pkg}" == "home-manager-path" ]]; then
    echo "${pkg} package priority update skipped."
    continue
  fi
  nix-env --set-flag priority 1 "${pkg}"
  echo "${pkg} package priority updated to '1'"
done

nix-channel --add https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz home-manager
nix-channel --update
