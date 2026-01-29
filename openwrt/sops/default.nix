{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.sops;
in

{
  options.sops = {
    enable = lib.mkEnableOption "sops";

    apply = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
    };

    file = lib.mkOption {
      type = lib.types.path;
      default = "${inputs.my.outPath}/${config.uci.system.hostname}.env";
    };

    hostname = lib.mkOption {
      type = lib.types.str;
      default = config.uci.system.hostname;
    };

    save = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
    };

    uciEncryptedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "^wireless\..*\.key"
        "password"
        "preshared_key"
        "private_key"
      ];
    };

    uciKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = cfg.uciEncryptedKeys ++ [
        "^network\.wg"
      ];
    };
  };

  config.sops = lib.mkIf cfg.enable {
    apply = pkgs.writeShellScriptBin "openwrt-sops-apply" ''
      set -euo pipefail

      file=${cfg.file}
      hostname=${cfg.hostname}

      while getopts ":h:" opt; do
        case "$opt" in
        h) hostname="$OPTARG" ;;
        esac
      done
      shift $((OPTIND - 1))

      ${lib.getExe pkgs.sops} decrypt "$file" | sed -e 's/^/set /' -e '$achanges' -e '$acommit' \
        | ssh "$hostname" "$@" 'uci batch; reload_config'
    '';

    save = pkgs.writeShellScriptBin "openwrt-sops-save" ''
      set -euo pipefail

      file=${cfg.file}
      hostname=${cfg.hostname}

      while getopts ":h:" opt; do
        case "$opt" in
        h) hostname="$OPTARG" ;;
        esac
      done
      shift $((OPTIND - 1))

      ssh "$hostname" "$@" 'uci show' | grep -E "${lib.concatStringsSep "|" cfg.uciKeys}" \
        | ${lib.getExe pkgs.sops} encrypt --encrypted-regex "${lib.concatStringsSep "|" cfg.uciEncryptedKeys}" \
          --filename-override .env --input-type dotenv > "${config.uci.system.hostname}.env" 
    '';
  };
}
