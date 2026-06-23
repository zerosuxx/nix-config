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
    settings = {
      "*" = {
        ForwardAgent = true;
      };
    };
  };
}
