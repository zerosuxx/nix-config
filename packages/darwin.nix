pkgs: {
  packages = with pkgs; [
    gnutar
    unixtools.watch.out
  ];

  brews = [
    "coreutils"
    "dagger"
    "ffmpeg"
    "mas"
    "mcp-toolbox"
    "mole"
    "tmux"
    "qemu"
  ];

  taps = [
    "zerosuxx/tap"
  ];

  casks = [
    "antigravity"
    "antigravity-ide"
    "brave-browser"
    "bruno"
    "codex-app"
    "claude"
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
    "telegram"
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
