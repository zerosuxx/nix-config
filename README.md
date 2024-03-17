# nix-config

### Install
```shell
# copy id_rsa file into ~/.ssh/id_rsa
$ nix-shell -p git openssh --run "git clone git@github.com:zerosuxx/nix-config.git"
```

### Bootstrap
```shell
$ sh scripts/install-home-manager.sh
$ nix-env --set-flag priority 1 nix-on-droid-path # required in nix-on-android
$ nix-shell -p git --run "sh scripts/hm-switch.sh $target"
```
