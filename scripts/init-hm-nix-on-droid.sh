#!/usr/bin/env sh

for pkg in $(nix-env -q); do
  if [[ "${pkg}" == "home-manager-path" ]]; then
    echo "${pkg} package priority update skipped."
    continue
  fi
  nix-env --set-flag priority 10 "${pkg}"
  echo "${pkg} package priority updated to '10'"
done

# nix-channel --add https://nixos.org/channels/nixos-25.05 nixpkgs
# nix-channel --update

export NIX_CONFIG="experimental-features = nix-command flakes"
nix-shell -p git openssh --run "nix run home-manager -- switch --impure --flake ."
