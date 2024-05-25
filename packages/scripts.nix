pkgs: with pkgs; [
  (writeShellScriptBin "sri-sha256-remote" ''
    set -eo pipefail
    
    curl -fsSL "$1" | openssl dgst -sha256 -binary | openssl base64 -
  '')
]