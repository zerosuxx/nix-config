{ config, lib, pkgs, ... }:

let
  codexWrapper = pkgs.writeShellScriptBin "codex" ''
    exec ${lib.getExe pkgs.codex} \
      -c 'model_reasoning_effort="medium"' \
      -c 'sandbox_mode="danger-full-access"' \
      -c 'features.daemon_auto_start=false' \
      -c 'tui.screen_reader_detection_done=true' \
      "$@"
  '';

in
{
  config = {
    programs.codex = {
      enable = true;
      package = lib.hiPrio codexWrapper;
    };
  };
}
