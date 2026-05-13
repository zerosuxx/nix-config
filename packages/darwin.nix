pkgs: {
  packages = with pkgs; [
    gnutar
    unixtools.watch.out
  ];

  brews = [
    "coreutils"
    "dagger"
    "mas"
    "mcp-toolbox"
    "mole"
    "qemu"
  ];

  taps = [
    "zerosuxx/tap"
  ];

  casks = [
    "bruno"
    "codex-app"
    "docker-desktop"
    "filezilla"
    "firefox"
    "google-chrome"
    "iterm2"
    "jetbrains-toolbox"
    "lens"
    "headlamp"
    "postman"
    "proxyman"
    "redis-insight"
    "slack"
    "sublime-text"
    "teamviewer"
    "transmission"
    "tunnelblick"
    "twingate"
    "vlc"
    "vnc-viewer"
    "visual-studio-code"
  ];

  masApps = {
    Bitwarden = 1352778147;
    Flyecut = 442160987;
    RemarkableDesktop = 1276493162;
    Wireguard = 1451685025;
  };
}
