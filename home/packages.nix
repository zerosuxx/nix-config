{
  config,
  inputs,
  lib,
  pkgs,
  cfg,
  outputs,
  ...
}:
let
  flattenPythonPath = import ../packages/flatten-pythonpath.nix pkgs;
  isPythonApp = p: p ? pythonModule || p ? overridePythonAttrs;

  packages = lib.concatLists [
    (import ../packages/base.nix pkgs)
    (import ../packages/scripts.nix pkgs)
    (pkgs.lib.optionals pkgs.stdenv.isLinux (import ../packages/linux.nix pkgs))
    (pkgs.lib.optionals pkgs.stdenv.isDarwin (import ../packages/darwin.nix pkgs).packages)
    (pkgs.lib.optionals true (import ../packages/ops.nix pkgs))
    (if cfg ? packages then (cfg.packages pkgs) else [])
  ];
in
{
  options.packagesModule.isTermux = lib.mkOption {
    type = lib.types.bool;
  };

  # Under proot every stat costs ~90 µs, so Python apps with hundreds of
  # sys.path entries take seconds to import; give them one merged entry.
  config.home.packages =
    if config.packagesModule.isTermux
    then map (p: if isPythonApp p then flattenPythonPath p else p) packages
    else packages;
}
