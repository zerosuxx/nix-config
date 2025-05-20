{ config, lib, pkgs, ... }:

{
  environment.packages = [];
  environment.etc."resolv.conf".text = "nameserver 100.95.0.251\n";
  system.stateVersion = "24.05";
}
