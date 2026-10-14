{ config, lib, pkgs, ... }:

{
  # Simply install just the packages
  environment.packages = with pkgs; [
    # User-facing stuff that you really really want to have
    vim # or some other editor, e.g. nano or neovim

    # Some common stuff that people expect to have
    #procps
    #killall
    #diffutils
    #findutils
    #utillinux
    #tzdata
    #hostname
    #man
    #gnugrep
    #gnupg
    #gnused
    #gnutar
    #bzip2
    #gzip
    #xz
    #zip
    #unzip
  ];

  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # home-manager-path shares the profile and ships newer nix/bash/less/busybox,
  # so a plain reinstall of nix-on-droid-path fails on file conflicts: the
  # priority flag is dropped on reinstall and nix-env 2.34 has no --priority.
  # Let home-manager-path win during the install, then demote nix-on-droid-path
  # so later home-manager switches (which reset their own flag) don't conflict.
  # build.activation is types.attrs (plain `//` merge), so mkForce on the
  # attribute is ignored; mkAfter sorts this definition last so it wins.
  build.activation = lib.mkAfter {
    installPackages = ''
      $DRY_RUN_CMD nix-env --set-flag priority 4 home-manager-path || true
      $DRY_RUN_CMD nix-env --install ${config.environment.path}
      $DRY_RUN_CMD nix-env --set-flag priority 10 nix-on-droid-path
    '';

    # The stock step stages this release's 2024 proot as /bin/.proot-static.new,
    # which login swaps in on the next cold start, replacing the patched proot
    # that the 26.05 packages need (scripts/fix-nix-on-droid-proot.sh, same path).
    installProotStatic = ''
      patched=/nix/store/dvf2ck9bkw7yyrlkjk87xz1anaxsgrd6-proot-termux-static-aarch64-unknown-linux-android-unstable-2026-02-20
      $DRY_RUN_CMD nix-store --realise "$patched" > /dev/null
      if ! diff /bin/proot-static "$patched/bin/proot-static" > /dev/null; then
        $DRY_RUN_CMD cp $VERBOSE_ARG "$patched/bin/proot-static" /bin/.proot-static.tmp
        $DRY_RUN_CMD chmod $VERBOSE_ARG u+w /bin/.proot-static.tmp
        $DRY_RUN_CMD mv $VERBOSE_ARG /bin/.proot-static.tmp /bin/.proot-static.new
      else
        $DRY_RUN_CMD rm -f $VERBOSE_ARG /bin/.proot-static.new
      fi
    '';
  };

  # glibc reads resolv.conf directly and can't reach Android's netd resolver.
  # The app's LocalDnsForwarder (127.0.0.1:2053) resolves through Android, so
  # VPN (Twingate) and Private DNS work; -p makes proot rewrite ports below 1024
  # by +2000, so queries to 127.0.0.1:53 reach it. Without the forwarder the
  # loopback refuses at once and glibc falls back to the public servers.
  build.extraProotOptions = [ "-p" ];

  environment.etc."resolv.conf".text = lib.mkForce ''
    nameserver 127.0.0.1
    nameserver 1.1.1.1
    nameserver 8.8.8.8
    options timeout:1
  '';

  # Read the changelog before changing this value
  system.stateVersion = "24.05";

  # Set up nix for flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Set your time zone
  #time.timeZone = "Europe/Berlin";
}
