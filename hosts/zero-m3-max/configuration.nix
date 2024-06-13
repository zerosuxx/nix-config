{ pkgs, lib, inputs, ... }:
{
  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  users.users.tmohos.home = "/Users/tmohos";
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  #environment.systemPackages =
  # [ pkgs.vim ];

  nix.package = pkgs.nix;

  # Enable experimental nix command and flakes
  # nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    auto-optimise-store = true
    experimental-features = nix-command flakes
  '' + lib.optionalString (pkgs.system == "aarch64-darwin") ''
    extra-platforms = x86_64-darwin aarch64-darwin
  '';

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true;
  programs.zsh.shellInit = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
  '';

  programs.nix-index.enable = true;

  security.pam.enableSudoTouchIdAuth = true;

  # environment.profiles = [
  #   "$HOME/.nix-profile"
  #   "/etc/profiles/per-user/$USER"
  # ];

  system = {
    stateVersion = 4;
    # activationScripts are executed every time you boot the system or run `nixos-rebuild` / `darwin-rebuild`.
    activationScripts.postUserActivation.text = ''
      # activateSettings -u will reload the settings from the database and apply them to the current session,
      # so we do not need to logout and login again to make the changes take effect.
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';

    defaults = {
      menuExtraClock.Show24Hour = true;
      dock = {
        mru-spaces = false;
        autohide = true;
        tilesize = 36;
        launchanim = true;
        # mouse-over-hilite-stack = true;
        orientation = "bottom";
      };

      screencapture.location = "~/Pictures";
      screensaver.askForPasswordDelay = 10;

      NSGlobalDomain = {
        AppleShowAllExtensions = true;
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
        # TODO: hide spotlight
        "com.apple.Spotlight" = {
          engagementCount-com.apple.Spotlight = 82;
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


  nix.configureBuildUsers = true;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";


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

    brews = [ "qemu" "mas" "coreutils" ];

    casks = [
      "docker"
      "firefox"
      "google-chrome"
      "iterm2"
      "jetbrains-toolbox"
      "microsoft-teams"
      "slack"
      "sublime-text"
      "transmission"
      "vlc"
      "visual-studio-code"
    ];

    masApps = {
      Flyecut = 442160987;
      Bitwarden = 1352778147;
    };
  };

}
