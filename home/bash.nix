{
  inputs,
  lib,
  pkgs,
  config,
  outputs,
  ...
}: {
  programs.bash = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    initExtra = ''
      exec zsh;
    '';
  };
}
