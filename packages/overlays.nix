{ nixpkgs-unstable
, nixpkgs-master
, zerosuxx-nixpkgs
, system
, packageSources ? { }
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

  sources = { inherit unstable master zerosuxx; };
in

final: prev: {
  azure-cli        = unstable.azure-cli;
  devbox           = unstable.devbox;
  gh               = unstable.gh;
  goreleaser       = unstable.goreleaser;
  google-cloud-sdk = unstable.google-cloud-sdk;
  helmfile         = unstable.helmfile;
  k9s              = unstable.k9s;
  oci-cli          = unstable.oci-cli;
  ruby_4_0         = unstable.ruby_4_0;

  bws            = zerosuxx.bws;
  coderabbit-cli = zerosuxx.coderabbit-cli;
  labctl         = zerosuxx.labctl;
  ollama         = zerosuxx.ollama;
  sofka          = zerosuxx.sofka;
  termux-am      = zerosuxx.termux-am;
  termux-api     = zerosuxx.termux-api;
  terraform      = zerosuxx.terraform;

  antigravity-cli    = master.antigravity-cli;
  claude-code        = master.claude-code;
  codex              = master.codex;
  github-copilot-cli = master.github-copilot-cli;
  terragrunt         = master.terragrunt;
}
// builtins.mapAttrs (name: source: sources.${source}.${name}) packageSources
