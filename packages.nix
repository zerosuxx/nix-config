pkgs: with pkgs;
(import ./packages/base.nix pkgs)
++ pkgs.lib.optionals (true) (import ./packages/ops.nix pkgs)
