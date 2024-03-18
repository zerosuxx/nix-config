{
  description = "Home Manager configurations";

  #  nixConfig = {
  #    experimental-features = [ "nix-command" "flakes" ];
  #  };

  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, utils, nix-index-database }:
    let
      pkgsForSystem = system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

      hosts = import ./hosts.nix;
      defaultModules = [ (import ./home.nix) ] ++ [ nix-index-database.hmModules.nix-index ];

      mkHomeConfiguration = args: home-manager.lib.homeManagerConfiguration (rec {
        modules = defaultModules ++ (args.modules or [ ]);
        pkgs = pkgsForSystem (args.system or "x86_64-linux");
      } // { inherit (args) extraSpecialArgs; });
    in
    utils.lib.eachSystem [
      "aarch64-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ]
      (system: rec { legacyPackages = pkgsForSystem system; }) // {
      homeConfigurations = builtins.mapAttrs
        (name: value:
          mkHomeConfiguration {
            inherit (value) system;
            extraSpecialArgs = value.config // { configName = name; };
          }
        )
        hosts;
    };
}
