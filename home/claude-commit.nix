{
  inputs,
  lib,
  pkgs,
  config,
  outputs,
  ...
}: let
  # Generates a conventional-commit subject line for the current changes.
  # Prints the subject on stdout, diagnostics on stderr; exit 1 = nothing to do.
  claude-commit-msg = pkgs.writeShellApplication {
    name = "claude-commit-msg";
    runtimeInputs = [ pkgs.git pkgs.coreutils pkgs.gnused pkgs.gnugrep ];
    text = ''
      MODEL="''${ZSH_CLAUDE_COMMIT_MODEL:-claude-haiku-4-5-20251001}"
      MAX_DIFF_BYTES="''${ZSH_CLAUDE_COMMIT_MAX_DIFF_BYTES:-100000}"

      git rev-parse --git-dir >/dev/null 2>&1 || { echo "not a git repo" >&2; exit 1; }

      # Prefer staged changes, but fall back to the worktree so this also
      # works before `git add`.
      diff=$(git diff --cached --no-color)
      scope="staged"
      stat=$(git diff --cached --stat --no-color)
      if [ -z "$diff" ]; then
        # `git diff` ignores untracked files, so include them explicitly —
        # this is the common shape before the first `git add`.
        untracked=$(git ls-files --others --exclude-standard)
        diff=$(git diff --no-color)
        scope="unstaged"
        stat=$(git diff --stat --no-color)
        if [ -n "$untracked" ]; then
          scope="unstaged + untracked"
          stat=$(printf '%s\n%s' "$stat" \
            "$(printf '%s' "$untracked" | sed 's/^/ new file: /')")
          # Intent-to-add stages names only, so the diff shows new file bodies
          # without touching the real index (undone right after). Names are
          # passed NUL-delimited so paths with spaces survive.
          # The same NUL-delimited list is reused for the undo, because after
          # --intent-to-add these paths are no longer reported as "others".
          names=$(mktemp)
          git ls-files --others --exclude-standard -z >"$names"
          xargs -0 --no-run-if-empty git add --intent-to-add -- \
            <"$names" >/dev/null 2>&1 || true
          diff=$(git diff --no-color)
          xargs -0 --no-run-if-empty git reset --quiet -- \
            <"$names" >/dev/null 2>&1 || true
          rm -f "$names"
        fi
      fi
      [ -n "$diff" ] || { echo "no changes to describe" >&2; exit 1; }

      # Keep the payload bounded: full diffstat always, diff body truncated.
      diff=$(printf '%s' "$diff" | head -c "$MAX_DIFF_BYTES")

      # Recent subjects teach the model this repo's actual prefix/scope style.
      recent=$(git log -10 --pretty=%s 2>/dev/null || true)

      {
        cat <<'PROMPT'
      You are writing a git commit subject line.

      Output rules — follow exactly:
      - Output ONLY the subject line. No quotes, no backticks, no code fence,
        no trailing period, no explanation, no leading "Subject:".
      - Conventional Commits format: <type>(<optional scope>): <description>
      - Imperative mood, lowercase description, at most 72 characters.
      - Match the style of the recent commits shown below (their type
        vocabulary and whether they use scopes).
      - Describe the intent of the change, not a file-by-file listing.
      PROMPT
        printf '\n## Recent commit subjects in this repo\n%s\n\n' "$recent"
        printf '## Diffstat (%s)\n%s\n\n' "$scope" "$stat"
        printf '## Diff (%s, may be truncated)\n%s\n' "$scope" "$diff"
      } | claude -p --model "$MODEL" 2>/dev/null \
        | tr -d '\r' \
        | grep -v '^[[:space:]]*$' \
        | head -1 \
        | sed -e 's/^["`'"'"']*//' -e 's/["`'"'"']*$//' \
              -e 's/^Subject:[[:space:]]*//' -e 's/[[:space:]]*$//' \
        | tr '"' "'"
    '';
  };
in {
  home.packages = [ claude-commit-msg ];

  # Ctrl+G on the command line inserts a Claude-generated commit subject.
  # Note: this rebinds zsh's default send-break.
  programs.zsh.initContent = lib.mkAfter ''
    _claude-commit-msg-widget() {
      emulate -L zsh
      setopt local_options no_notify no_monitor extended_glob

      local left=$LBUFFER right=$RBUFFER
      local spinner=$'⠉⠙⠹⠸⠼⠴⠦⠧⠇⠏'

      # Run in the background so a spinner can show the few seconds of latency.
      local tmp err
      tmp=$(mktemp) || return 1
      err=$(mktemp) || { command rm -f $tmp; return 1; }
      ${lib.getExe claude-commit-msg} >$tmp 2>$err &
      local pid=$!
      local i=0
      while kill -0 $pid 2>/dev/null; do
        zle -R "''${spinner[$(( i % 10 + 1 ))]} asking claude…"
        (( i++ ))
        sleep 0.12
      done
      wait $pid
      local rc=$?

      local msg errmsg
      msg=$(<$tmp); errmsg=$(<$err)
      command rm -f $tmp $err

      if (( rc != 0 )) || [[ -z $msg ]]; then
        zle -M "claude-commit: ''${errmsg:-no message generated}"
        return 1
      fi

      local stripped=''${left## }
      if [[ -z ''${left//[[:space:]]/} ]]; then
        # Empty line: build the whole command.
        LBUFFER="git commit -m \"$msg\""
      elif [[ $stripped == (|*[[:space:]])(git|g)[[:space:]](commit|c)([[:space:]]|) ]]; then
        # Bare `git commit` / `g c`: supply the -m flag ourselves.
        LBUFFER="''${left%%[[:space:]]##} -m \"$msg\""
      elif [[ $stripped == (|*[[:space:]])(git|g)[[:space:]](cm|cma)([[:space:]]|) ]]; then
        # The `cm`/`cma` aliases already mean `commit -m`.
        LBUFFER="''${left%%[[:space:]]##} \"$msg\""
      else
        # Mid-command, typically right after `-m "`: insert in place.
        LBUFFER="$left$msg"
      fi
      RBUFFER=$right

      zle redisplay
    }

    zle -N _claude-commit-msg-widget
    bindkey '^G' _claude-commit-msg-widget
  '';
}
