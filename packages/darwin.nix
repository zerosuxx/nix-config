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
    "ollama"
    "mcp-toolbox"
    # "stripe"
  ];

  taps = [
    "homebrew/bundle"
    "zerosuxx/tap"
    # "stripe/stripe-cli"
  ];

  casks = [
    "bruno"
    "docker-desktop"
    "filezilla"
    "firefox"
    "google-chrome"
    "iterm2"
    "jetbrains-toolbox"
    "lens"
    "headlamp"
    "microsoft-outlook"
    "microsoft-teams"
    "postman"
    "proxyman"
    "slack"
    "sublime-text"
    "transmission"
    "twingate"
    "vlc"
    "vnc-viewer"
    "visual-studio-code"
  ];

  masApps = {
    Flyecut = 442160987;
    Bitwarden = 1352778147;
    Wireguard = 1451685025;
    RemarkableDesktop = 1276493162;
  };
}
