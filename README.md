# nix-config

### Install
```shell
# copy id_rsa file into ~/.ssh/id_rsa
$ nix-shell -p git openssh --run "git clone git@github.com:zerosuxx/nix-config.git"
```

### Bootstrap
```shell
$ sh scripts/enable-flakes-current-user.sh
$ sh scripts/install-home-manager.sh
```

### Switch
```shell
# first
$ nix-shell -p git openssh --run "sh scripts/hm-switch.sh $target"
$ sw $target
```
