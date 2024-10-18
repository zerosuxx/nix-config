{ nixpkgs-unstable, system }:

final: prev: {
  devbox = nixpkgs-unstable.legacyPackages.${system}.devbox;
}