# nix-config

### Install
```shell
# copy id_rsa file into ~/.ssh/id_rsa
$ nix-shell -p git openssh --run "git clone git@github.com:zerosuxx/nix-config.git"
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
