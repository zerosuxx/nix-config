# nix-config

### Install
```shell
$ sh <(curl -L https://nixos.org/nix/install)
$ nix-shell -p git openssh --run "git clone https://github.com/zerosuxx/nix-config.git \
  && sed -i '' 's#https://github.com/#git@github.com:#g' nix-config/.git/config"
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
