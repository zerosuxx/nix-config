{ config, lib, pkgs, specialArgs, ... }:

let
  inherit (lib) mkIf;
  inherit (pkgs.stdenv) isLinux isDarwin;
  inherit (specialArgs) configName;

  bashSettings = import ./bash.nix pkgs configName;
  gitSettings = import ./git.nix pkgs;
  packages = import ./packages.nix pkgs;
  variables = import ./variables.nix;
  isTermux = builtins.getEnv "TERMUX_VERSION" != "";
in
{
  # nixpkgs.config.allowUnfree = true;
  # nixpkgs.overlays = [ ];

  home.packages = packages;
  home.homeDirectory = builtins.getEnv "HOME";
  home.username = builtins.getEnv "USER";
  home.stateVersion = "23.11";
  home.sessionVariables = variables;

  home.activation = mkIf (isTermux) {
    termuxProperties = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run mkdir -p "$HOME/.termux" && cat "${builtins.toString ./config/termux/termux.properties}" > "$HOME/.termux/termux.properties" && cat "${builtins.toString ./config/termux/colors.properties}" > "$HOME/.termux/colors.properties"
      run ln -f -s /android/system/bin/linker64 /system/bin/linker64
    '';
  };

  programs = {
    home-manager = {
      enable = true;
    };

    bash = bashSettings;
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

    zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      enableCompletion = true;

      plugins = [
        {
          file = "powerlevel10k.zsh-theme";
          name = "powerlevel10k";
          src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k";
        }
        {
          file = "p10k.zsh";
          name = "powerlevel10k-config";
          src = ./dotfiles/zsh;
        }
      ];

      oh-my-zsh = {
         enable = true;
         theme = "robbyrussell";
         plugins = [
           "git"
           "npm"
           "history"
           "node"
         ];
      };
    };
  };
}
