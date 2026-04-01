{
  description = "My Nix configurations";

  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zerosuxx-nixpkgs = {
      url = "github:zerosuxx/nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, utils, nixpkgs, nixpkgs-unstable, nixpkgs-master, nix-index-database, nix-darwin, nix-homebrew, home-manager, zerosuxx-nixpkgs, ... }:
    let
      lib = nixpkgs.lib;

      overlays = system: import ./packages/overlays.nix {
        nixpkgs-unstable = nixpkgs-unstable;
        nixpkgs-master = nixpkgs-master;
        zerosuxx-nixpkgs = zerosuxx-nixpkgs;
        inherit system;
      };

      pkgsForSystem = system:
        import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
          overlays = [ (overlays system) ];
        };

      hosts = import ./hosts.nix;
      defaultModules = [ (import ./home.nix) ] ++ [ nix-index-database.homeModules.nix-index ];

      # Darwin hosts defined in hosts.nix (entries with a `darwin` attribute)
      darwinHosts = lib.filterAttrs (_: v: v ? darwin) hosts;
      hostnameOf = name: lib.last (lib.splitString "@" name);
      usernameOf = name: lib.head (lib.splitString "@" name);

      darwinConfigsFromHosts = lib.mapAttrs'
        (name: value:
          let username = usernameOf name; in
          lib.nameValuePair (hostnameOf name) (nix-darwin.lib.darwinSystem {
            system = value.system;
            modules = [
              nix-homebrew.darwinModules.nix-homebrew
              {
                nix-homebrew = {
                  enable = true;
                  enableRosetta = value.system == "aarch64-darwin";
                  user = username;
                  mutableTaps = true;
                  autoMigrate = true;
                };
              }
              (value.darwin.configModule or ./hosts/darwin/configuration.nix)
              home-manager.darwinModules.home-manager
              {
                nixpkgs = {
                  config = { allowUnfree = true; };
                  overlays = [ (overlays value.system) ];
                };
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  users.${username} = import ./home.nix;
                  extraSpecialArgs = { cfg = value.config or { }; };
                };
              }
            ];
            specialArgs = {
              inherit inputs;
              username = username;
              darwinConfig = value.darwin;
            };
          })
        )
        darwinHosts;

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
            extraSpecialArgs = { cfg = value.config; };
          }
        )
        (lib.filterAttrs (_: v: !(v ? darwin)) hosts);
    } // {
      darwinConfigurations = darwinConfigsFromHosts;
    };
}
