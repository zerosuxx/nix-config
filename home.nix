{ config, lib, pkgs, specialArgs, ... }:

let
  bashsettings = import ./bash.nix pkgs;
  packages = import ./packages.nix;

  inherit (lib) mkIf;
  inherit (pkgs.stdenv) isLinux isDarwin;
in
{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [ ];

  programs.home-manager.enable = true;
  home.packages = packages pkgs;
  home.homeDirectory = builtins.getEnv "HOME";
  home.username = "nix-on-droid";
  home.stateVersion = "23.11";

  home.activation = mkIf (builtins.getEnv "TERMUX_VERSION" != "") {
    termuxProperties = lib.hm.dag.entryAfter ["writeBoundary"] ''
      run mkdir "$HOME/.termux" && cat "${builtins.toString ./config/termux/termux.properties}" > "$HOME/.termux/termux.properties"
    '';
  };
  
  programs.bash = bashsettings;
  programs.direnv.enable = true;
  programs.htop = {
    enable = true;
    settings = {
      left_meters = [ "LeftCPUs2" "Memory" "Swap" ];
      left_right = [ "RightCPUs2" "Tasks" "LoadAverage" "Uptime" ];
      setshowProgramPath = false;
      treeView = true;
    };
  };
  programs.jq.enable = true;
  
  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "Tamas Mohos";
    userEmail = "zerosuxx@gmail.com";
    aliases = {
      a = "add";
      c = "commit";
      ca = "commit --amend";
      can = "commit --amend --no-edit";
      cl = "clone";
      cm = "commit -m";
      co = "checkout";
      cp = "cherry-pick";
      cpx = "cherry-pick -x";
      d = "diff";
      f = "fetch";
      fo = "fetch origin";
      fu = "fetch upstream";
      lol = "log --graph --decorate --pretty=oneline --abbrev-commit";
      lola = "log --graph --decorate --pretty=oneline --abbrev-commit --all";
      pl = "pull";
      pr = "pull -r";
      ps = "push";
      psf = "push -f";
      rb = "rebase";
      rbi = "rebase -i";
      r = "remote";
      ra = "remote add";
      rr = "remote rm";
      rv = "remote -v";
      rs = "remote show";
      st = "status";
    };
    extraConfig = {
      pull = {
        rebase=true;
      };
      git.path = toString pkgs.git;
    };
    includes = [];
  };
}
