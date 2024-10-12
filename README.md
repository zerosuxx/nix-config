# nix-config

### Install
```shell
$ sh <(curl -L https://nixos.org/nix/install)
$ nix-shell -p git openssh --run "git clone https://github.com/zerosuxx/nix-config.git \
  && sed -i'' 's#https://github.com/#git@github.com:#g' nix-config/.git/config"
```

### Bootstrap with Home Manager
```shell
$ export NIX_CONFIG="experimental-features = nix-command flakes"
$ nix run home-manager -- switch --impure --flake .
```

### Bootstrap with Nix Darwin
```shell
$ export NEW_HOSTNAME="zero-m3-max"
$ sudo scutil --set HostName $NEW_HOSTNAME.localdomain
$ sudo scutil --set LocalHostName $NEW_HOSTNAME
$ sudo scutil --set ComputerName $NEW_HOSTNAME
$ export NIX_CONFIG="experimental-features = nix-command flakes"
$ xcode-select --install
$ softwareupdate --install-rosetta
$ nix run nix-darwin -- switch --impure --flake .
```

### Update flake
```shell
$ nix flake update
```
