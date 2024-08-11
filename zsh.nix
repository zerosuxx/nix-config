pkgs: configName: isTermux: {
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
    kctx = "kubectx";
    d = "docker";
    dc = "docker compose";
    nfl = "nix flake lock";
    nfu = "nix flake update";
    nflu = "nix flake lock --update-input";
    hm = "home-manager";
    rmds = "find . -name '.DS_Store' -type f -delete";
    dutop = "du -h -x -d 1 .";
    rld = "${if pkgs.stdenv.hostPlatform.isDarwin then "darwin-rebuild" else "home-manager"} switch --impure --flake ~/nix-config";
    rlb = "${if pkgs.stdenv.hostPlatform.isDarwin then "darwin-rebuild" else "home-manager"} switch --impure --rollback --flake ~/nix-config";
  };
  
  initExtra = ''
    ${if builtins.hasAttr "tzdata" pkgs then ''[[ -z "$TZDIR" ]] && export TZDIR="${pkgs.tzdata}/share/zoneinfo"'' else ""}
    ${if isTermux then ''
      export PATH=/system/bin:$PATH
      export NPM_CONFIG_PREFIX=~/.npm
    '' else ""}

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
