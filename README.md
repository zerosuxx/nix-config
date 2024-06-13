# nix-config

### Install
```shell
$ sh <(curl -L https://nixos.org/nix/install)
$ nix-shell -p git openssh --run "git clone https://github.com/zerosuxx/nix-config.git \
  && sed -i'' 's#https://github.com/#git@github.com:#g' nix-config/.git/config"
```

### Bootstrap with Home Manager
```shell
$ sh scripts/install-home-manager.sh
$ nix-shell -p git --run "sh scripts/hm-switch.sh $target"
```

### Bootstrap with Nix Darwin
```shell
$ sudo scutil --set HostName zero-m3-max
$ sudo scutil --set LocalHostName zero-m3-max
$ export NIX_CONFIG="experimental-features = nix-command flakes"
$ xcode-select --install
$ softwareupdate --install-rosetta
$ nix run nix-darwin -- switch --flake ~/nix-config
```

### Update flake
```shell
$ nix flake update
```
