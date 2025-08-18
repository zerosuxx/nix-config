{ nixpkgs-unstable, nixpkgs-master, zerosuxx-nixpkgs, system }:

final: prev: {
  devbox = nixpkgs-unstable.legacyPackages.${system}.devbox;
  google-cloud-sdk = nixpkgs-unstable.legacyPackages.${system}.google-cloud-sdk;
  gh = nixpkgs-unstable.legacyPackages.${system}.gh;
  terragrunt = nixpkgs-master.legacyPackages.${system}.terragrunt;
  terraform = zerosuxx-nixpkgs.packages.${system}.terraform;
  k9s = nixpkgs-unstable.legacyPackages.${system}.k9s;
}
