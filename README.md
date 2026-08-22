# nix-config

### Install nix
```shell
$ sh <(curl -L https://nixos.org/nix/install)
```

### Update nix channel
```shell
$ nix-channel --add https://nixos.org/channels/nixos-25.11 nixpkgs
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
$ xcode-select --install
$ softwareupdate --install-rosetta
# Log in to the App Store with your Apple ID and download an app (e.g. Flycut).
$ sudo NIX_CONFIG="experimental-features = nix-command flakes" nix run nix-darwin -- switch --impure --flake .
```

### Bootstrap with Nix-on-Droid

First, install the patched `proot-static` required for Nix-on-Droid 26.05:

```shell
$ sh scripts/fix-nix-on-droid-proot.sh
```

Restart the shell/session so that the patched `proot-static` is activated.

Then initialize the Home Manager environment:

```shell
$ sh scripts/init-hm-nix-on-droid.sh
```

Alternatively, if using Nix-on-Droid directly:

```shell
$ nix-on-droid switch --flake .
```

### Update flake
```shell
$ nix flake update
$ nix flake update zerosuxx-nixpkgs
$ nix flake update nixpkgs-master
```
