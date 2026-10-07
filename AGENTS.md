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

macOS hosts are exported separately, under `darwinConfigurations`:

```sh
nix eval --json '.#darwinConfigurations' --apply 'builtins.attrNames'
```

Current configuration keys:

`homeConfigurations`

- `nix-on-droid@localhost` — aarch64-linux, the Termux device
- `zero@home-zero-linux-pc` — x86_64-linux
- `zero@zeroGo` — x86_64-linux

`darwinConfigurations`

- `zero-m3-max` — aarch64-darwin
- `zero-m5-max` — aarch64-darwin
- `zero-imac` — x86_64-darwin, pinned to 26.05 (see below)

Note the darwin keys drop the user prefix: `hosts.nix` defines them as
`tmohos@zero-m3-max` / `tmohos@zero-m5-max`, but they are exported bare.

## Per-host release pinning

Nixpkgs 26.05 is the last release supporting x86_64-darwin, so a host can opt out
of the main inputs in `hosts.nix`:

- `release = "26.05";` — uses the `*-2605` inputs (`nixpkgs`, `nix-darwin`,
  `home-manager`) instead of the main ones. `zerosuxx-nixpkgs` is shared by
  all hosts.
- `overlayInputs = { unstable = "…"; master = "…"; };` — replaces the inputs
  behind the overlay's `unstable` / `master` sources, given as flake input
  names. Either key may be omitted.

Hosts without these keep the main inputs, so those can be bumped independently.

## Evaluating a configuration

Evaluation of `home.homeDirectory` reads `$HOME` from the environment. A plain
`nix eval` runs in pure mode, so `$HOME` is empty and evaluation fails with:

```
error: A definition for option `home.homeDirectory' is not of type `absolute path'.
Definition values:
- In `<unknown-file>': ""
```

This is **not** a config error. `home.nix` reads both `$HOME` and `$USER` via
`builtins.getEnv`, so both must be present — dropping `USER` fails instead with
`Failed assertions: - Username could not be determined`. Pass `--impure` with the
environment set explicitly:

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

# 4. Activate, so the new version lands in the profile / on PATH
rld
```

Prefer `nix flake update <input>` over a bare `nix flake update`, which churns
every input and produces a large, hard-to-review lock diff.

## Activating changes

A `flake.lock` bump only repins the input — the profile and `$PATH` keep serving
the previously activated generation until the configuration is switched. So after
updating the lock (or editing any config), activate with the `rld` alias:

```sh
rld
```

It is defined in `home/zsh.nix` and expands per platform to
`home-manager switch --impure --flake ~/nix-config`, or on Darwin to
`sudo darwin-rebuild switch --impure --flake ~/nix-config`. The companion alias
`rlb` rolls back to the previous generation.

Because it is a zsh alias, it is unavailable in a non-interactive shell — run the
expanded command there, or ask the user to run `rld` themselves.

## Conventions

- Nix files end with a trailing newline.
- Commit messages follow the existing style: `fix:`, `chore:`, `feat:` prefixes.
