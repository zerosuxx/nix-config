pkgs: with pkgs; [
  busybox
  # Pins nix to flake.lock; on Darwin nix-darwin's nix.package does this
  nix
  strace.out
]
