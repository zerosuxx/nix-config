pkgs: {
  enable = true;
  autosuggestion.enable = true;
  syntaxHighlighting.enable = false;
  enableCompletion = true;

  shellAliases = {
    ll = "ls -alF";
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    g = "git";
    k = "kubectl";
    kctx = "kubectx";
    d = "docker";
    dc = "docker compose";
    gco = "git checkout";
    gst = "git status";
    nfl = "nix flake lock";
    nfu = "nix flake update";
    nflu = "nix flake lock --update-input";
    hm = "home-manager";
    # sw = "cd ${builtins.getEnv "PWD"} && sh scripts/hm-switch.sh ${configName}";
    rld = "darwin-rebuild switch --flake ~/nix-config";
    rlb = "darwin-rebuild switch --rollback --flake ~/nix-config";
    rmds = "find . -name '.DS_Store' -type f -delete";
    dutop = "du -h -x -d 1 .";
  };
  
  initExtra = ''
    ${if builtins.hasAttr "tzdata" pkgs then ''[[ -z "$TZDIR" ]] && export TZDIR="${pkgs.tzdata}/share/zoneinfo"'' else ""}

    zstyle ":completion:*:*:make:*" tag-order "targets"
    zstyle ":completion:*" matcher-list "" "m:{a-zA-Z}={A-Za-z}"
    zle_bracketed_paste=()
  '';

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
}
