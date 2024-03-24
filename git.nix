pkgs: {
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
      rebase = true;
    };
    git.path = toString pkgs.git;
  };
  includes = [ ];
}
