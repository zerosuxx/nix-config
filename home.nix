{ config, lib, pkgs, specialArgs, ... }:

let
  inherit (lib) mkIf;
  inherit (pkgs.stdenv) isLinux isDarwin;
  inherit (specialArgs) configName;

  isTermux = builtins.getEnv "TERMUX_VERSION" != "";
  bashSettings = import ./bash.nix pkgs configName;
  zshSettings = import ./zsh.nix pkgs configName isTermux;
  gitSettings = import ./git.nix pkgs;
  packages = import ./packages.nix pkgs;
  variables = import ./variables.nix;
in
{
  # nixpkgs.config.allowUnfree = true;
  # nixpkgs.overlays = [ ];

  home.packages = packages;
  home.homeDirectory = builtins.getEnv "HOME";
  home.username = builtins.getEnv "USER";
  home.stateVersion = "23.11";
  home.sessionVariables = variables;
  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  home.activation = mkIf (isTermux) {
    termuxInit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run mkdir -p "$HOME/.termux" && cat "${builtins.toString ./dotfiles/termux/termux.properties}" > "$HOME/.termux/termux.properties" && cat "${builtins.toString ./dotfiles/termux/colors.properties}" > "$HOME/.termux/colors.properties"
      run ln -f -s /android/system/bin/linker64 /system/bin/linker64
      run ln -f -s /android/system/bin/ping /system/bin/ping
      run mkdir -p ~/.npm/lib
    '';
  };

  programs = {
    home-manager = {
      enable = true;
    };

    bash = mkIf(isLinux) bashSettings;
    git = gitSettings;

    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    htop = {
      enable = true;
      settings = {
        left_meters = [ "LeftCPUs2" "Memory" "Swap" ];
        left_right = [ "RightCPUs2" "Tasks" "LoadAverage" "Uptime" ];
        setshowProgramPath = false;
        treeView = true;
      };
    };

    jq = {
      enable = true;
    };

    nix-index = {
      enable = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    zsh = zshSettings;
  };
}
