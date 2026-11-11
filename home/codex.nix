{ config, lib, pkgs, ... }:

let
  codexWrapper = pkgs.writeShellScriptBin "codex" ''
    exec ${lib.getExe pkgs.codex} \
      -c 'model="gpt-6.1-sol"' \
      -c 'model_reasoning_effort="medium"' \
      -c 'sandbox_mode="danger-full-access"' \
      -c 'features.daemon_auto_start=false' \
      -c 'tui.screen_reader_detection_done=true' \
      "$@"
  '';

in
{
  config = lib.mkIf config.nixOnDroidModule.isTermux {
    programs.codex = {
      enable = true;
      package = lib.hiPrio codexWrapper;
    };
  };
}
