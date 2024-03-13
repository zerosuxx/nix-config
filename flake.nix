{
  description = "Home Manager configurations";

  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    homeManager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, homeManager, utils }:
  let
      pkgsForSystem = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

    in utils.lib.eachSystem [ "aarch64-linux" "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ] (system: rec {
      legacyPackages = pkgsForSystem system;
  }) // {
    homeConfigurations = {
      "termux" = homeManager.lib.homeManagerConfiguration {
        pkgs = pkgsForSystem ("aarch64-linux");
        modules = [ (import ./home.nix) ];
        # configuration = {pkgs, ...}: {
        #   programs.home-manager.enable = true;
        #   home.packages = [ pkgs.hello ];
        # };

        # system = "aarch64-linux";
        # homeDirectory = "/data/data/com.termux.nix/files/home";
        # username = "nix-on-droid";
        # stateVersion = "23.11";
      };
    };
  };
}