{ config, lib, ... }:
let
  # Out-of-store, so the files stay editable and `nix flake update` can write the lock.
  configDir = "${config.home.homeDirectory}/nix-config/nix-on-droid";

  # Re-run `nix-on-droid switch` only when its config changed since the last run.
  configHash = builtins.hashString "sha256" (lib.concatMapStrings
    (f: builtins.readFile (../nix-on-droid + "/${f}"))
    [ "flake.nix" "flake.lock" "nix-on-droid.nix" ]);
  stampFile = "${config.xdg.stateHome}/nix-on-droid/config.sha256";
in
{
  options.nixOnDroidModule.isTermux = lib.mkOption {
    type = lib.types.bool;
  };

  config = lib.mkIf config.nixOnDroidModule.isTermux {
    xdg.configFile."nix-on-droid".source = config.lib.file.mkOutOfStoreSymlink configDir;

    # A fresh Nix-on-Droid install creates ~/.config/nix-on-droid as a real directory
    # (the bootstrap flake), which would block the link above; set it aside once.
    home.activation.nixOnDroidMoveBootstrapConfig = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
      target="${config.xdg.configHome}/nix-on-droid"
      if [ -d "$target" ] && [ ! -L "$target" ]; then
        run mv "$target" "$target.bootstrap-$(date +%Y%m%d%H%M%S)"
      fi
    '';

    # After installPackages: nix-on-droid reinstalls its own path into the same profile.
    home.activation.nixOnDroidSwitch = lib.hm.dag.entryAfter [ "installPackages" "linkGeneration" ] ''
      if [ "$(cat "${stampFile}" 2>/dev/null)" != "${configHash}" ]; then
        # path: rather than the enclosing git repo: activation has no git on PATH.
        if run "$HOME/.nix-profile/bin/nix-on-droid" switch --flake "path:${configDir}"; then
          run mkdir -p "$(dirname "${stampFile}")"
          run sh -c 'echo "$1" > "$2"' _ "${configHash}" "${stampFile}"
        else
          warnEcho "nix-on-droid switch failed; it will be retried on the next switch"
        fi
      fi
    '';
  };
}
