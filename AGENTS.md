# AGENTS.md

## Repository

Nix flake config for multiple hosts, running on nix-on-droid (Termux) on aarch64-linux.

## Flake output structure

**Important:** this flake exports `homeConfigurations`, *not* `nixOnDroidConfigurations` —
even for the nix-on-droid host. Evaluating `.#nixOnDroidConfigurations.…` fails with
"flake does not provide attribute". Check with:

```sh
nix flake show --json
nix eval --json '.#homeConfigurations' --apply 'builtins.attrNames'
```

Current configuration keys:

- `nix-on-droid@localhost` (aarch64-linux, the Termux device)
- `zero@home-zero-linux-pc`
- `zero@zeroGo`

## Evaluating a configuration

Evaluation of `home.homeDirectory` reads `$HOME` from the environment. A plain
`nix eval` runs in pure mode, so `$HOME` is empty and evaluation fails with:

```
error: A definition for option `home.homeDirectory' is not of type `absolute path'.
Definition values:
- In `<unknown-file>': ""
```

This is **not** a config error. Pass `--impure` with the environment set explicitly:

```sh
env HOME=/data/data/com.termux.nix/files/home USER=nix-on-droid \
  nix eval --impure --raw \
  '.#homeConfigurations."nix-on-droid@localhost".activationPackage.drvPath'
```

Evaluating the full activation package on-device is slow (minutes). Use a generous
timeout, and prefer narrower evals when checking that a single package resolves.

## Package sources

`packages/overlays.nix` maps package names onto three pinned inputs. Keep each
block internally aligned on `=`, with a blank line between blocks:

- `unstable` — `nixpkgs-unstable`
- `master` — `nixpkgs-master` (currently `claude-code`, `terragrunt`)
- `zerosuxx` — `zerosuxx-nixpkgs`, consumed as `.packages.${system}` (a flake,
  not a plain nixpkgs tree)

Package lists live in `packages/*.nix` (e.g. `ops.nix`), kept alphabetically sorted.
Adding a package normally means editing **two** files: the overlay and the list.

## Adding a package from zerosuxx/nixpkgs

The `zerosuxx-nixpkgs` input is pinned in `flake.lock`. A package pushed to that
repo is invisible until the lock is bumped — the symptom is
`attribute '<name>' missing` at eval time, not a fetch error.

```sh
# 1. Confirm the package is actually exported by the input
nix eval --json 'github:zerosuxx/nixpkgs#packages.aarch64-linux' \
  --apply 'builtins.attrNames'

# 2. Bump only that input (leaves other inputs pinned)
nix flake update zerosuxx-nixpkgs

# 3. Add to packages/overlays.nix and the relevant packages/*.nix list
```

Prefer `nix flake update <input>` over a bare `nix flake update`, which churns
every input and produces a large, hard-to-review lock diff.

## flake.lock hygiene

`flake.lock` is generated — never hand-edit it. If it ends up with conflict markers
(commonly from a `git pull --rebase` autostash that failed to reapply), discard it
and regenerate rather than resolving by hand:

```sh
git checkout -- flake.lock
nix flake update <input>   # re-apply the intended bump
```

Check `git stash list` after such a conflict: a leftover `autostash` entry may hold
a stale copy of the working tree. Diff it against the current files before dropping
or restoring it — restoring blindly can revert newer committed work.

## Conventions

- Nix files end with a trailing newline.
- Commit messages follow the existing style: `fix:`, `chore:`, `feat:` prefixes.
