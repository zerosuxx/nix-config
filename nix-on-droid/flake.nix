{
  description = "Basic example of Nix-on-Droid system config.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    # The terminal font only: Iosevka Term Nerd Font before 3.5.0 lacks glyphs that
    # tuios and Claude Code draw (⎿ ✻ ✽ ✢ ⚠ and some Nerd Font icons).
    nixpkgs-fonts.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-fonts, nix-on-droid }: {

    nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
      pkgs = import nixpkgs { system = "aarch64-linux"; };
      modules = [ ./nix-on-droid.nix ];
      extraSpecialArgs.fontPkgs = import nixpkgs-fonts { system = "aarch64-linux"; };
    };

  };
}
