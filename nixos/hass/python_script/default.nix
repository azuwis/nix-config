{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.services.hass;
in
{
  options.services.hass = {
    python_script = mkEnableOption "python_script";
  };

  config = mkIf (cfg.enable && cfg.python_script) {
    services.home-assistant.config.python_script = { };
    systemd.services.home-assistant.preStart = ''
      ln -fs ${./python_scripts} ${config.services.home-assistant.configDir}/python_scripts
    '';
  };
}
