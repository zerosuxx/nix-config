{ lib, pkgs, specialArgs, ... }:

let
  inherit (lib) mkIf;
  inherit (pkgs.stdenv) isLinux isDarwin;

  isTermux = builtins.getEnv "TERMUX_VERSION" != "";
in
{
  imports = [
    ./home/bash.nix
    ./home/git.nix
    ./home/k9s.nix
    ./home/packages.nix
    ./home/variables.nix
    ./home/zsh.nix
  ] ++ lib.optional (builtins.pathExists ./home/ssh.nix) ./home/ssh.nix;
  
  zshModule.isTermux = isTermux;
  
  home = {
    homeDirectory = mkIf isLinux (builtins.getEnv "HOME");
    username = mkIf isLinux (builtins.getEnv "USER");
    stateVersion = "24.11";
    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/go/bin"
      "$HOME/.krew/bin"
    ];

    activation = mkIf isTermux {
      termuxInit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run sh -c 'mkdir -p "$HOME/.termux" && \
          { [ -f "$HOME/.termux/termux.properties" ] || \
            cat "${builtins.toString ./dotfiles/termux/termux.properties}" > "$HOME/.termux/termux.properties"; } && \
          { [ -f "$HOME/.termux/colors.properties" ] || \
            cat "${builtins.toString ./dotfiles/termux/colors.properties}" > "$HOME/.termux/colors.properties"; }'
        run ln -f -s /android/system/bin/linker64 /system/bin/linker64
        run ln -f -s /android/system/bin/ping /system/bin/ping
        run sh -c '[ -L "$HOME/sdcard" ] || ln -s /sdcard "$HOME/sdcard"'
        run mkdir -p "$HOME/.npm/lib"
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
