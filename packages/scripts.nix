pkgs: with pkgs; [
  (writeShellScriptBin "sri-sha256-remote" ''
    set -eo pipefail
    
    echo "sha256-$(curl -fL "$1" | openssl dgst -sha256 -binary | openssl base64 -)"
  '')

  (writeShellScriptBin "docker-compose" ''
    docker compose --compatibility "$@"
  '')

  (writeShellScriptBin "port-check" ''
    lsof -i "tcp:$@"
  '')
  
  (writeShellScriptBin "kube-merge-config" ''
    KUBECONFIG=~/.kube/config:$1 kubectl config view --flatten
  '')
]