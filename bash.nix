pkgs: configName: {
  enable = true;
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
    sw = "cd ${builtins.getEnv "PWD"} && sh scripts/hm-switch.sh ${configName}";
    hm = "home-manager";
  };

  initExtra = ''
    git_prompt_path=${pkgs.git}/share/bash-completion/completions/git-prompt.sh
    [ -f "$git_prompt_path" ] && source "$git_prompt_path"
    git_compl_path=${pkgs.git}/share/bash-completion/completions/git
    [ -f "$git_compl_path" ] && source "$git_compl_path"

    RED="\[\033[0;31m\]"
    GREEN="\[\033[1;32m\]"
    BLUE="\[\033[0;34m\]"
    PURPLE="\[\033[1;34m\]"
    NO_COLOR="\[\033[00m\]"

    git_prompt_path=${pkgs.git}/share/bash-completion/completions/git-prompt.sh
    if [ -f "$git_prompt_path" ] && ! command -v __git_ps1 > /dev/null; then
      source "$git_prompt_path"
    fi

    prompt_symbol=$(test "$UID" == "0" && echo "$RED#$NO_COLOR" || echo "$")
    export PS1="$GREEN[\D{%H:%M:%S}]\u$NO_COLOR:$PURPLE\w$NO_COLOR$BLUE\`__git_ps1\`$NO_COLOR$prompt_symbol "

    ${if builtins.hasAttr "tzdata" pkgs then ''[[ -z "$TZDIR" ]] && export TZDIR="${pkgs.tzdata}/share/zoneinfo"'' else ""}

    if [[ "$OSTYPE" == "darwin"* ]]; then
      export TERM=xterm-256color
    fi

    if [ -n "$VIRTUAL_ENV" ]; then
      env=$(basename "$VIRTUAL_ENV")
      export PS1="($env) $PS1"
    fi

    if [ -n "$IN_NIX_SHELL" ]; then
      export PS1="(nix-shell) $PS1"
    fi

    if [ ! -z "$WSL_DISTRO_NAME" -a -d ~/.nix-profile/etc/profile.d ]; then
      for f in ~/.nix-profile/etc/profile.d/* ; do
        source $f
      done
    fi
  '';
}
