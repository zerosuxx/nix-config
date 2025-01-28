{ nixpkgs-unstable, system }:

final: prev: {
  devbox = nixpkgs-unstable.legacyPackages.${system}.devbox;
  google-cloud-sdk = nixpkgs-unstable.legacyPackages.${system}.google-cloud-sdk;
  terragrunt = nixpkgs-unstable.legacyPackages.${system}.terragrunt;
}
