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
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        forwardAgent = true;
      };
    };
  };
}