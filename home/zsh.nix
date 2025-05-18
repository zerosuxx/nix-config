{ inputs, lib, pkgs, config, outputs, ... }: {
  options.zshModule.isTermux = lib.mkOption {
    type = lib.types.bool;
  };
  
  config = {
    programs.zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
    
      shellAliases = {
        ll = "ls -alhF";
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        g = "git";
        k = "kubectl";
        kctx = "kubectx";
        d = "docker";
        dc = "docker compose";
        db = "devbox";
        tf = "terraform";
        tg = "terragrunt";
        nfl = "nix flake lock";
        nfu = "nix flake update";
        nflu = "nix flake lock --update-input";
        hm = "home-manager";
        rmds = "find . -name '.DS_Store' -type f -delete";
        dutop = "du -h -x -d 1 .";
        rld = "${if config.zshModule.isTermux then "nix-on-droid switch" else if pkgs.stdenv.hostPlatform.isDarwin then "darwin-rebuild switch --impure" else "home-manager switch --impure"} --flake ~/nix-config";
        rlb = "${if pkgs.stdenv.hostPlatform.isDarwin then "darwin-rebuild switch --impure --rollback --flake ~/nix-config" else "$(home-manager generations | sed -n '2p' | cut -d '>' -f 2)/activate"}";
        myip = "curl -fsSL http://ip-api.com";
      };
      
      initExtra = ''
        ${if builtins.hasAttr "tzdata" pkgs then ''[[ -z "$TZDIR" ]] && export TZDIR="${pkgs.tzdata}/share/zoneinfo"'' else ""}
        ${if config.zshModule.isTermux then ''
          export PATH=/system/bin:$PATH
          export NPM_CONFIG_PREFIX=~/.npm
          export UDOCKER_USE_PROOT_EXECUTABLE=/system/bin/proot-static
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
          src = ../dotfiles/zsh;
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
