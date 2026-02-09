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
      default = "${inputs.my.outPath}/${config.uci.system.hostname}.json";
    };

    hostname = lib.mkOption {
      type = lib.types.str;
      default = config.uci.system.hostname;
    };

    save = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
    };

    sopsEncryptedRegex = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "password"
        "preshared_key"
        "private_key"
        "key"
      ];
    };

    uciKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "password"
        "preshared_key"
        "private_key"
        ''^wireless\..*\.key''
        ''^network\.wg''
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    files.file."usr/bin/uci-import".source = ./uci-import.js;
    files.file."etc/uci-defaults/99-sops".source =
      pkgs.runCommand "files-etc-uci-defaults-99-sops" { preferLocalBuild = true; }
        ''
          echo 'uci-import <<EOF' >$out
          cat ${cfg.file} | ${lib.getExe pkgs.jq} '
          del(.sops) | walk(
            if type == "object" then
              with_entries(select(.value | (type == "string" and startswith("ENC[")) | not)) |
              select(keys != [".type"] and length > 0)
            else . end
          )' >>$out
          echo 'EOF' >>$out
          echo 'uci commit' >>$out
        '';

    sops.apply = pkgs.writeShellScriptBin "openwrt-sops-apply" ''
      set -euo pipefail

      file=${cfg.file}
      args=(${cfg.hostname})
      if [ "$#" -gt 0 ]; then
        args=("$@")
      fi

      ssh "''${args[@]}" 'cat >/tmp/uci-import.js' <${./uci-import.js}
      ${lib.getExe pkgs.sops} decrypt "$file" | ssh "''${args[@]}" 'ucode /tmp/uci-import.js'
      ssh "''${args[@]}" '
      echo
      uci changes
      echo
      echo -n "Commit?[Yn]"
      read -r answer
      if [ -n "$answer" ] && [ "$answer" != "Y" ]; then
        set -x
        rm /tmp/.uci/*
      else
        set -x
        uci commit
        reload_config
      fi
      '
    '';

    sops.save = pkgs.writeShellScriptBin "openwrt-sops-save" ''
      set -euo pipefail

      args=(${cfg.hostname})
      if [ "$#" -gt 0 ]; then
        args=("$@")
      fi

      ssh "''${args[@]}" 'ucode - "${lib.concatStringsSep "|" cfg.uciKeys}"' <${./uci-export.js} \
        | ${lib.getExe pkgs.sops} encrypt --encrypted-regex "^(${lib.concatStringsSep "|" cfg.sopsEncryptedRegex})$" \
          --filename-override .json --input-type json > "${config.uci.system.hostname}.json" 
    '';
  };
}
