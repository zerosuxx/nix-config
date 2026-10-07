{
  description = "My Nix configurations";

  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    brew-src = {
      url = "github:Homebrew/brew/7.0.8";
      flake = false;
    };
    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
      inputs.brew-src.follows = "brew-src";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zerosuxx-nixpkgs = {
      url = "github:zerosuxx/nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Pinned 26.05 release, for hosts with `release = "26.05"` in hosts.nix
    # (e.g. Intel Macs, whose support ends with 26.05)
    nixpkgs-2605.url = "github:nixos/nixpkgs/nixos-26.05";
    nix-darwin-2605 = {
      url = "github:LnL7/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs-2605";
    };
    home-manager-2605 = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-2605";
    };
  };

  outputs = inputs@{ self, utils, nixpkgs, nixpkgs-unstable, nixpkgs-master, nix-index-database, nix-darwin, nix-homebrew, brew-src, home-manager, zerosuxx-nixpkgs, nixpkgs-2605, nix-darwin-2605, home-manager-2605, ... }:
    let
      lib = nixpkgs.lib;

      # Input sets selectable per host via `release` in hosts.nix
      releases = {
        default = { inherit nixpkgs nix-darwin home-manager; };
        "26.05" = {
          nixpkgs = nixpkgs-2605;
          nix-darwin = nix-darwin-2605;
          home-manager = home-manager-2605;
        };
      };
      releaseOf = host: releases.${host.release or "default"};

      # Per-host override of the overlay sources via `overlayInputs` in hosts.nix,
      # given as flake input names, e.g. { unstable = "nixpkgs-2605"; }
      overlayInput = host: key: default:
        if host ? overlayInputs.${key} then inputs.${host.overlayInputs.${key}} else default;

      overlays = host: system: import ./packages/overlays.nix {
        nixpkgs-unstable = overlayInput host "unstable" nixpkgs-unstable;
        nixpkgs-master = overlayInput host "master" nixpkgs-master;
        zerosuxx-nixpkgs = zerosuxx-nixpkgs;
        packageSources = host.packageSources or { };
        inherit system;
      };

      pkgsForSystem = host: system:
        import (releaseOf host).nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
          overlays = [ (overlays host system) ];
        };

      hosts = import ./hosts.nix;
      defaultModules = [ (import ./home.nix) ] ++ [ nix-index-database.homeModules.nix-index ];

      darwinHosts = lib.filterAttrs (_: v: v ? darwin) hosts;
      usernameOf = name: lib.head (lib.splitString "@" name);
      hostnameOf = name: lib.last (lib.splitString "@" name);

      darwinConfigsFromHosts = lib.mapAttrs'
        (name: value:
          let
            username = usernameOf name;
            rel = releaseOf value;
          in
          lib.nameValuePair (hostnameOf name) (rel.nix-darwin.lib.darwinSystem {
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
              rel.home-manager.darwinModules.home-manager
              {
                nixpkgs = {
                  config = { allowUnfree = true; };
                  overlays = [ (overlays value value.system) ];
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

      mkHomeConfiguration = args: (releaseOf args.host).home-manager.lib.homeManagerConfiguration (rec {
        modules = defaultModules ++ (args.modules or [ ]);
        pkgs = pkgsForSystem args.host (args.system or "x86_64-linux");
      } // { inherit (args) extraSpecialArgs; });
    in
    utils.lib.eachSystem [
      "aarch64-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ]
      (system: rec { legacyPackages = pkgsForSystem { } system; }) // {
      homeConfigurations = builtins.mapAttrs
        (name: value:
          mkHomeConfiguration {
            inherit (value) system;
            host = value;
            extraSpecialArgs = { cfg = value.config; };
          }
        )
        (lib.filterAttrs (_: v: !(v ? darwin)) hosts);
    } // {
      darwinConfigurations = darwinConfigsFromHosts;
    };
}
