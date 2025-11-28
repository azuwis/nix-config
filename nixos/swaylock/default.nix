{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.programs.swaylock;
in
{
  options.programs.swaylock = {
    enable = lib.mkEnableOption ''
      swaylock.

      Note that PAM must be configured to enable swaylock to perform
      authentication.

      On NixOS, this is by default enabled with the sway module, but
      for other compositors it can currently be enabled using:

      ```nix
      security.pam.services.swaylock = {};
      ```
    '';

    package = lib.mkPackageOption pkgs "swaylock" { };

    settings = lib.mkOption {
      type =
        with lib.types;
        attrsOf (oneOf [
          bool
          float
          int
          path
          str
        ]);
      default = { };
      description = ''
        Default arguments to {command}`swaylock`. An empty set
        disables configuration generation.
      '';
      example = {
        color = "808080";
        font-size = 24;
        indicator-idle-visible = false;
        indicator-radius = 100;
        line-color = "ffffff";
        show-failed-attempts = true;
      };
    };

    finalPackage = lib.mkOption {
      default =
        if (cfg.settings == { }) then
          cfg.package
        else
          (pkgs.wrapper {
            package = cfg.package;
            flags = lib.mapAttrsToList (
              n: v:
              if v == true then "--${n}" else "--${n}" + "=" + (if builtins.isPath v then "${v}" else toString v)
            ) (lib.filterAttrs (n: v: v != false) cfg.settings);
          });
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.finalPackage ];
  };
}
