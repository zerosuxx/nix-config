# nix-config

### Install
```shell
$ sh <(curl -L https://nixos.org/nix/install)
$ nix-shell -p openssh --run "ssh-keygen -N '' -t ed25519 -f ~/.ssh/id_ed25519"
$ nix-shell -p git openssh --run "git clone github.com:zerosuxx/nix-config.git"
```

### Bootstrap
```shell
$ sh scripts/install-home-manager.sh
$ nix-shell -p git --run "sh scripts/hm-switch.sh $target"
```

### Update flake
```shell
$ nix flake update
```
