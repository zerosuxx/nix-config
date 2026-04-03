{ pkgs, lib, username, darwinConfig ? {}, ... }:
let
  touchIdAuth = darwinConfig.touchIdAuth or false;
  isArm = pkgs.stdenv.hostPlatform.isAarch64;
  brewPath = if isArm then "/opt/homebrew/bin/brew" else "/usr/local/bin/brew";
  homebrew = import ../../packages/darwin.nix pkgs;
in
{
  users.users.${username}.home = "/Users/${username}";

  nix = {
    package = pkgs.nix;
    extraOptions = ''
      auto-optimise-store = true
      experimental-features = nix-command flakes
    '' + lib.optionalString isArm ''
      extra-platforms = x86_64-darwin aarch64-darwin
    '';
  };

  programs = {
    zsh = {
      enable = true;
      shellInit = ''
        eval "$(${brewPath} shellenv)"
      '';
    };
    nix-index = {
      enable = true;
    };
  };

  security.pam.services.sudo_local.touchIdAuth = touchIdAuth;
  ids.gids.nixbld = 350;

  system = {
    primaryUser = username;
    stateVersion = 4;

    defaults = {
      menuExtraClock.Show24Hour = true;
      dock = {
        mru-spaces = false;
        autohide = true;
        tilesize = 36;
        launchanim = true;
        orientation = "bottom";
      };

      screencapture.location = "~/Pictures";
      screensaver.askForPasswordDelay = 10;

      NSGlobalDomain = {
        AppleShowAllExtensions = false;
        ApplePressAndHoldEnabled = false;
        # 120, 90, 60, 30, 12, 6, 2
        KeyRepeat = 2;
        # 120, 94, 68, 35, 25, 15
        InitialKeyRepeat = 25;
      };

      CustomUserPreferences = {
        AppleGlobalDomain = {
          NSQuitAlwaysKeepsWindows = 1;
        };
        "com.apple.Spotlight" = {
          MenuItemHidden = 1;
        };
        "com.apple.dock" = {
          showAppExposeGestureEnabled = 1;
          expose-group-apps = 1;
        };
        "com.apple.finder" = {
          AppleShowAllFiles = true;
          AppleShowAllExtensions = true;
          ShowExternalHardDrivesOnDesktop = true;
          ShowHardDrivesOnDesktop = true;
          ShowMountedServersOnDesktop = true;
          ShowRemovableMediaOnDesktop = true;
          _FXSortFoldersFirst = true;
          _FXShowPosixPathInTitle = true;
          FXPreferredViewStyle = "Nlsv";
          FXDefaultSearchScope = "SCcf";
        };
        "com.apple.desktopservices" = {
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
        "com.apple.screensaver" = {
          idleTime = 600;
        };
        "com.apple.HIToolbox" = {
          AppleFnUsageType = 0;
        };
        "com.apple.symbolichotkeys" = {
          AppleSymbolicHotKeys = {
            # previous input source (option + space)
            "60" = {
              enabled = true;
              value = {
                parameters = [ 32 49 524288 ];
                type = "standard";
              };
            };
            # disable dictation shortcut with fn button
            "164" = {
              enabled = 0;
              value = {
                parameters = [ 65535 65535 0 ];
                type = "standard";
              };
            };
          };
        };
      };
    };
  };

  homebrew = {
    enable = true;
    onActivation = {
      upgrade = true;
      autoUpdate = true;
      cleanup = "zap";
    };

    global = {
      autoUpdate = true;
      brewfile = true;
      lockfiles = true;
    };

    inherit (homebrew) brews;
    inherit (homebrew) taps;
    inherit (homebrew) casks;
    inherit (homebrew) masApps;
  };
}

