pkgs: {
  packages = with pkgs; [
    gnutar
    unixtools.watch.out
  ];

  brews = [
    "qemu"
    "mas"
    "coreutils"
    "dagger"
  ];

  taps = [
    "homebrew/bundle"
  ];

  casks = [
    "docker"
    "https://raw.githubusercontent.com/zerosuxx/homebrew-tap/main/Casks/filezilla.rb"
    "firefox"
    "google-chrome"
    "iterm2"
    "jetbrains-toolbox"
    "microsoft-outlook"
    "microsoft-teams"
    "postman"
    "proxyman"
    "slack"
    "sublime-text"
    "transmission"
    "vlc"
    "vnc-viewer"
    "visual-studio-code"
  ];

  masApps = {
    Flyecut = 442160987;
    Bitwarden = 1352778147;
    Twingate = 1501592214;
    Wireguard = 1451685025;
  };
}
