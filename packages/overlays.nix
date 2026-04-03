{ nixpkgs-unstable, nixpkgs-master, zerosuxx-nixpkgs, system }:

let
  unstable = nixpkgs-unstable.legacyPackages.${system};
  master   = nixpkgs-master.legacyPackages.${system};
  zerosuxx = zerosuxx-nixpkgs.packages.${system};
in

final: prev: {
  devbox           = unstable.devbox;
  gh               = unstable.gh;
  goreleaser       = unstable.goreleaser;
  google-cloud-sdk = unstable.google-cloud-sdk;
  helmfile         = unstable.helmfile;
  k9s              = unstable.k9s;
  ollama           = unstable.ollama;

  labctl     = zerosuxx.labctl;
  terraform  = zerosuxx.terraform;

  terragrunt = master.terragrunt;
}
