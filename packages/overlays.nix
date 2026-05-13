{ nixpkgs-unstable
, nixpkgs-master
, zerosuxx-nixpkgs
, system
}:

let
  unstable = import nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };

  master = import nixpkgs-master {
    inherit system;
    config.allowUnfree = true;
  };

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
  ruby_4_0         = unstable.ruby_4_0;

  labctl     = zerosuxx.labctl;
  terraform  = zerosuxx.terraform;

  terragrunt = master.terragrunt;
}
