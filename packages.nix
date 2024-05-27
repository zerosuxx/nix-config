pkgs: with pkgs;
(import ./packages/base.nix pkgs)
++ (import ./packages/scripts.nix pkgs)
++ pkgs.lib.optionals (pkgs.stdenv.isLinux) (import ./packages/linux.nix pkgs)
++ pkgs.lib.optionals (pkgs.stdenv.isDarwin) (import ./packages/darwin.nix pkgs)
++ pkgs.lib.optionals (true) (import ./packages/ops.nix pkgs)
