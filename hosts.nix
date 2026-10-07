{
  "nix-on-droid@localhost" = {
    system = "aarch64-linux";
    config = {
      packages = pkgs: with pkgs; [
        termux-am
        termux-api
      ];
    };
  };

  "zero@home-zero-linux-pc" = {
    system = "x86_64-linux";
    config = { };
  };

  "zero@zeroGo" = {
    system = "x86_64-linux";
    config = {
      env = {
       GDK_SCALE = 2;
       GDK_DPI_SCALE = 0.75;
       DONT_PROMPT_WSL_INSTALL = 1;
      };
      packages = pkgs: with pkgs; [
        fastfetch
        vscode
      ];
    };
  };

  "tmohos@zero-m3-max" = {
    system = "aarch64-darwin";
    darwin = {
      touchIdAuth = true;
      configModule = ./hosts/zero-m3-max/configuration.nix;
    };
    config = { };
  };

  "tmohos@zero-m5-max" = {
    system = "aarch64-darwin";
    darwin = {
      touchIdAuth = true;
      configModule = ./hosts/zero-m5-max/configuration.nix;
    };
    config = { };
  };

  # Intel iMac: nixpkgs / nix-darwin / home-manager support ends with 26.05
  "tmohos@zero-imac" = {
    system = "x86_64-darwin";
    release = "26.05";
    overlayInputs = {
      unstable = "nixpkgs-2605";
      master   = "nixpkgs-2605";
    };
    packageSources = {
      antigravity-cli = "zerosuxx";
    };
    darwin = { };
    config = { };
  };
}
