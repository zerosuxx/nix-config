{ lib, pkgs, specialArgs, ... }:

let
  inherit (lib) mkIf;
  inherit (pkgs.stdenv) isLinux isDarwin;
  # inherit (specialArgs) configName;

  isTermux = builtins.getEnv "TERMUX_VERSION" != "";
  zshSettings = import ./zsh.nix pkgs isTermux;
  gitSettings = import ./git.nix pkgs;
  k9sSettings = import ./modules/k9s.nix pkgs;
  packages = import ./packages.nix pkgs;
  variables = import ./variables.nix;
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

    git = gitSettings;

    direnv = {
      enable = true;
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

    k9s = k9sSettings;
  };
}
