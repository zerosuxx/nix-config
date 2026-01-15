{ nixpkgs-unstable, nixpkgs-master, zerosuxx-nixpkgs, system }:

final: prev: {
  devbox           = nixpkgs-unstable.legacyPackages.${system}.devbox;
  gh               = nixpkgs-unstable.legacyPackages.${system}.gh;
  google-cloud-sdk = nixpkgs-unstable.legacyPackages.${system}.google-cloud-sdk;
  helmfile         = nixpkgs-unstable.legacyPackages.${system}.helmfile;
  k9s              = nixpkgs-unstable.legacyPackages.${system}.k9s;
  labctl           = zerosuxx-nixpkgs.packages.${system}.labctl;
  ollama           = nixpkgs-unstable.legacyPackages.${system}.ollama;
  terraform        = zerosuxx-nixpkgs.packages.${system}.terraform;
  terragrunt       = nixpkgs-master.legacyPackages.${system}.terragrunt;
}
