pkgs: configName: {
  enable = true;
  autosuggestion.enable = true;
  syntaxHighlighting.enable = true;
  enableCompletion = true;

  shellAliases = {
    ll = "ls -alF";
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    g = "git";
    k = "kubectl";
    d = "docker";
    dc = "docker compose";
    gco = "git checkout";
    gst = "git status";
    nfl = "nix flake lock";
    nfu = "nix flake update";
    nflu = "nix flake lock --update-input";
    sw = "home-manager switch --flake ${builtins.getEnv "PWD"} --impure";
    hm = "home-manager";
  };
  
  initExtra = ''
    ${if builtins.hasAttr "tzdata" pkgs then ''[[ -z "$TZDIR" ]] && export TZDIR="${pkgs.tzdata}/share/zoneinfo"'' else ""}

    zstyle ':completion:*:*:make:*' tag-order 'targets'
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
