{
  "nix-on-droid@localhost" = {
    system = "aarch64-linux";
    config = { };
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
      };
      packages = pkgs: with pkgs; [
        neofetch
      ];
    };
  };
}
