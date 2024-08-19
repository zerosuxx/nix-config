{
  inputs,
  lib,
  pkgs,
  config,
  outputs,
  ...
}: {
  home.sessionVariables = {
    EDITOR = "nano";
    NIX_CONFIG = "experimental-features = nix-command flakes";
    TZ = "Europe/Budapest";
  };
}
