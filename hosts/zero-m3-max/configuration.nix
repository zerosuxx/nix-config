{ pkgs, lib, inputs, username, ... }:
let
    homebrew = import ../../packages/darwin.nix pkgs;
in
{
  users.users.${username}.home = "/Users/${username}";
  nixpkgs.hostPlatform = "aarch64-darwin";

  nix = {
    package = pkgs.nix;
    extraOptions = ''
      auto-optimise-store = true
      experimental-features = nix-command flakes
    '' + lib.optionalString (pkgs.system == "aarch64-darwin") ''
      extra-platforms = x86_64-darwin aarch64-darwin
    '';
  };

  programs = {
    zsh = {
      enable = true;
      shellInit = ''
        eval "$(/opt/homebrew/bin/brew shellenv)"
      '';
    };
    nix-index = {
      enable = true;
    };
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  # environment.profiles = [
  #   "$HOME/.nix-profile"
  #   "/etc/profiles/per-user/$USER"
  # ];

  system = {
    primaryUser = username;
    stateVersion = 4;
    # activationScripts are executed every time you boot the system or run `nixos-rebuild` / `darwin-rebuild`.
    # activationScripts.postUserActivation.text = ''
    #   # activateSettings -u will reload the settings from the database and apply them to the current session,
    #   # so we do not need to logout and login again to make the changes take effect.
    #   /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    # '';

    defaults = {
      menuExtraClock.Show24Hour = true;
      dock = {
        mru-spaces = false;
        autohide = true;
        tilesize = 36;
        launchanim = true;
        # mouse-over-hilite-stack = true;
        orientation = "bottom";
        persistent-apps = [
          # "/System/Library/CoreServices/Finder.app"
          "/Applications/iTerm.app"
          "/Applications/Firefox.app"
          "/Applications/Google Chrome.app"
          "/Applications/Slack.app"
          "/Users/${username}/Applications/Chrome Apps.localized/Gmail.app"
          "/Users/${username}/Applications/Chrome Apps.localized/Google Chat.app"
          "/Users/${username}/Applications/Chrome Apps.localized/Google Calendar.app"
          "/Users/${username}/Applications/WebStorm.app"
          "/Users/${username}/Applications/IntelliJ IDEA Ultimate.app"
          "/Users/${username}/Applications/Fleet.app"
          "/Applications/Visual Studio Code.app"
          "/Applications/Sublime Text.app"
          "/System/Applications/Utilities/Activity Monitor.app"
          "/System/Applications/Calendar.app"
          "/System/Applications/Launchpad.app"
          "/System/Applications/System Settings.app"
          "/System/Applications/Reminders.app"
          "/System/Applications/Notes.app"
          "/System/Applications/App Store.app"
        ];
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
          # When performing a search, search the current folder by default
          FXDefaultSearchScope = "SCcf";
        };
        "com.apple.desktopservices" = {
          # Avoid creating .DS_Store files on network or USB volumes
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
                parameters = [32 49 524288];
                type = "standard";
              };
            };
            # disable dictation shortcut with fn button
            "164" = {
              enabled = 0;
              value = {
                parameters = [65535 65535 0];
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
