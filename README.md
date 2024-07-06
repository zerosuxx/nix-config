# nix-config

### Install
```shell
$ sh <(curl -L https://nixos.org/nix/install)
$ nix-shell -p git openssh --run "git clone https://github.com/zerosuxx/nix-config.git \
  && sed -i'' 's#https://github.com/#git@github.com:#g' nix-config/.git/config"
```

### Bootstrap
```shell
$ nix run home-manager -- switch --impure --flake .
```

### Update flake
```shell
$ nix flake update
```
