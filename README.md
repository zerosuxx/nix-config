# nix-config

### Install nix
```shell
$ sh <(curl -L https://nixos.org/nix/install)
```

### Update nix channel
```shell
$ nix-channel --add https://nixos.org/channels/nixos-25.05 nixpkgs
$ nix-channel --update
```

### Clone this repository
```shell
$ nix-shell -p git openssh --run "git clone https://github.com/zerosuxx/nix-config.git \
  && sed -i'' 's#https://github.com/#git@github.com:#g' nix-config/.git/config"
```

### Setup SSH
```shell
$ nix-shell -p curl --run bash
$ mkdir -p ~/.ssh
$ curl -s https://github.com/zerosuxx.keys | head -n 1 > ~/.ssh/id_rsa.pub
$ echo "zerosuxx@gmail.com $(cat ~/.ssh/id_rsa.pub)" > ~/.ssh/allowed_signers
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

### Bootstrap with Nix-On-Droid
```shell
$ sh scripts/init-hm-nix-on-droid.sh # for use home-manager
$ nix-on-droid switch --flake .
```

### Update flake
```shell
$ nix flake update
```
