{
  inputs,
  lib,
  pkgs,
  config,
  outputs,
  ...
}: {
  programs.ssh = {
    enable = true;
    forwardAgent = true;
    #extraConfig = "ForwardAgent yes";
  };
}