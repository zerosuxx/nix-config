{ lib, pkgs, specialArgs, ... }:

let
  inherit (lib) mkIf;
  inherit (pkgs.stdenv) isLinux isDarwin;

  isTermux = builtins.getEnv "TERMUX_VERSION" != "";
in
{
  imports = [
    ./home/bash.nix
    ./home/claude-commit.nix
    ./home/codex.nix
    ./home/git.nix
    ./home/k9s.nix
    ./home/nix-on-droid.nix
    ./home/packages.nix
    ./home/variables.nix
    ./home/zsh.nix
  ] ++ lib.optional (builtins.pathExists ./home/ssh.nix) ./home/ssh.nix;
  
  nixOnDroidModule.isTermux = isTermux;
  
  home = {
    homeDirectory = mkIf isLinux (builtins.getEnv "HOME");
    username = mkIf isLinux (builtins.getEnv "USER");
    stateVersion = "24.11";
    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/go/bin"
      "$HOME/.krew/bin"
    ];

    activation = mkIf isDarwin {
      nativeMessagingHosts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run mkdir -p "$HOME/Library/Application Support/Mozilla/NativeMessagingHosts"
      '';
    };
  };

  programs = {
    home-manager = {
      enable = true;
    };

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
  };
}
