{ config, lib, pkgs, ... }:

{
  environment.packages = [];
  environment.etc."resolv.conf".text = "nameserver 1.1.1.1\nnameserver 8.8.8.8\nnameserver 100.95.0.251";
  system.stateVersion = "24.05";
}