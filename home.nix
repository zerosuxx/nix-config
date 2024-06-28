{ lib, pkgs, specialArgs, ... }:

let
  inherit (lib) mkIf;
  inherit (pkgs.stdenv) isLinux isDarwin;
  # inherit (specialArgs) configName;

  bashSettings = import ./bash.nix pkgs;
  zshSettings = import ./zsh.nix pkgs;
  gitSettings = import ./git.nix pkgs;
  packages = import ./packages.nix pkgs;
  variables = import ./variables.nix;
  isTermux = builtins.getEnv "TERMUX_VERSION" != "";
in
{
  # nixpkgs.config.allowUnfree = true;
  # nixpkgs.overlays = [ ];

  home.homeDirectory = mkIf(isLinux) (builtins.getEnv "HOME");
  home.username = mkIf(isLinux) (builtins.getEnv "USER");
  home.packages = packages;
  home.stateVersion = "24.05";
  home.sessionVariables = variables;
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/go/bin"
  ];

  home.activation = mkIf (isTermux) {
    termuxProperties = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run mkdir -p "$HOME/.termux" && cat "${builtins.toString ./dotfiles/termux/termux.properties}" > "$HOME/.termux/termux.properties" && cat "${builtins.toString ./dotfiles/termux/colors.properties}" > "$HOME/.termux/colors.properties"
      run ln -f -s /android/system/bin/linker64 /system/bin/linker64
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
