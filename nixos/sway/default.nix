{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    ;
  cfg = config.programs.sway;
in
{
  options.programs.sway = {
    extraConfig = mkOption {
      type = lib.types.lines;
      default = "";
    };
  };

  config = mkIf cfg.enable {
    programs.wayland.enable = true;

    # vim -d "$(nix path-info n#sway-unwrapped)/etc/sway/config" ./config
    environment.etc."sway/config".source = pkgs.replaceVars ./config {
      inherit (cfg) extraConfig;
      inherit (config.programs.wayland) terminal;
      wallpaper = pkgs.wallpapers.default;
      DEFAULT_AUDIO_SINK = null;
      DEFAULT_AUDIO_SOURCE = null;
    };

    environment.etc."swaynag/config".text = ''
      edge=bottom
    '';

    programs.sway.extraConfig =
      lib.concatMapStrings (entry: "exec ${lib.concatStringsSep " " entry}\n") (
        builtins.attrValues config.programs.wayland.startup
      )
      # Systemd integration, does not work on multiple sway instances, so not putting to `config` file
      + ''
        include /etc/sway/config.d/*
      '';

    programs.sway = {
      wrapperFeatures.gtk = true;
      # sway complains even nvidia GPU is only used for offload
      extraOptions = [ "--unsupported-gpu" ];
      # override default extraPackages, some packages are already setted in programs.wayland
      extraPackages = with pkgs; [
        swappy
        sway-contrib.grimshot
      ];
    };
  };
}
