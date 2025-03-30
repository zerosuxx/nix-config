{
  inputs,
  lib,
  pkgs,
  config,
  outputs,
  ...
}: {
  programs.git = {
    enable = true;
    lfs = {
      enable = true;
    };
    userName = "Tamas Mohos";
    userEmail = "zerosuxx@gmail.com";
    aliases = {
      a = "add";
      c = "commit";
      cnv = "commit --no-verify";
      ca = "commit --amend";
      can = "commit --amend --no-edit";
      canv = "commit --amend --no-verify";
      cl = "clone";
      cm = "commit -m";
      cma = "commit -a -m";
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
      pr = "pull --rebase";
      pra = "pull --rebase --autostash";
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
      sw = "switch";
      swc = "switch -c";
    };
    extraConfig = {
      git = {
        path = toString pkgs.git;
      };
      init = {
        defaultBranch = "main";
      };
      pull = {
        rebase = true;
      };
      commit = {
        gpgsign = true;
      };
      gpg = {
        format = "ssh";
      };
      user = {
        signingkey = "~/.ssh/id_rsa.pub";
      };
    };
    includes = [ ];
  };
}
