{ config, options, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.photoprism;
  configFile = pkgs.writeTextFile {
    name = "photoprism.yml";
    text = generators.toYAML { } ({
      StoragePath = "${cfg.dataDir}/storage";
      OriginalsPath = "${cfg.dataDir}/originals";
      ImportPath = "${cfg.dataDir}/import";
    } // cfg.config);
  };

in
{
  options.services.photoprism = {
    enable = mkEnableOption "photoprism";

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/photoprism";
      description = ''
        The directory where photoprism stores its data files.
      '';
    };

    user = mkOption {
      type = types.str;
      default = "photoprism";
      description = ''
        User account under which photoprism runs.
      '';
    };

    group = mkOption {
      type = types.str;
      default = "photoprism";
      description = ''
        Group under which photoprism runs.
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.photoprism;
      defaultText = literalExpression "pkgs.photoprism";
      description = ''
        The photoprism package to use.
      '';
    };

    config = mkOption {
      type = with types; attrsOf (oneOf [ bool int str path package ]);
      default = { };
      example = literalExpression ''
        {
          DisableTensorFlow = true;
          Experimental = true;
          HttpHost = "127.0.0.1";
          HttpPort = 2342;
          JpegQuality = 92;
          OriginalsLimit = 10000;
          IMPORT_PATH = "${cfg.dataDir}/import";
          ORIGINALS_PATH = "${cfg.dataDir}/originals";
          STORAGE_PATH = "${cfg.dataDir}/storage";
        }
      '';
      description = ''
        Options in https://github.com/photoprism/photoprism/blob/release/internal/config/options.go
      '';
    };

  };

  config = mkIf cfg.enable {

    users.groups = mkIf (cfg.group == "photoprism") {
      photoprism = { };
    };

    users.users = mkIf (cfg.user == "photoprism") {
      photoprism = {
        group = cfg.group;
        shell = pkgs.bashInteractive;
        home = cfg.dataDir;
        createHome = true;
        homeMode = "0750";
        description = "Photoprism Daemon user";
        isSystemUser = true;
      };
    };

    systemd = {
      services = {
        photoprism = {
          description = "photoprism system service";
          after = [ "network.target" ];
          path = [ cfg.package pkgs.bash ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            User = cfg.user;
            Group = cfg.group;
            Type = "simple";
            Restart = "on-failure";
            WorkingDirectory = cfg.dataDir;
            ExecStart = "${cfg.package}/bin/photoprism --defaults-yaml ${configFile} start";
          };
        };
      };
    };
  };
}
