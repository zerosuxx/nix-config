{
  description = "My Nix configurations";

  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = inputs@{ self, utils, nixpkgs, nix-index-database, home-manager, nix-darwin, nix-homebrew, ... }:
    let
      username = builtins.getEnv "USER";
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
    } // {
      darwinConfigurations = {
        zero-m3-max = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                # Install Homebrew under the default prefix
                enable = true;

                # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
                enableRosetta = true;

                # User owning the Homebrew prefix
                user = username;

                # Optional: Enable fully-declarative tap management
                #
                # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
                mutableTaps = true;

                autoMigrate = true;
              };
            }
            ./hosts/zero-m3-max/configuration.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./home.nix;

              # Optionally, use home-manager.extraSpecialArgs to pass
              # arguments to home.nix
              home-manager.extraSpecialArgs = { specialArgs = { }; };
            }
          ];
          specialArgs = { inherit inputs; config = { inherit username; }; };
        };
      };
    };
}
