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
      ca = "commit --amend";
      can = "commit --amend --no-edit";
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
      user = {
        signingkey = "~/.ssh/id_rsa.pub";
      };
      gpg = {
        format = "ssh";
        ssh = {
          allowedSignersFile = "~/.ssh/allowed_signers";
        };
      };
      tag = {
         gpgSign = true;
      };
    };
    includes = [ ];
  };
}
