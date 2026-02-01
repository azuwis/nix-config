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
        "password"
        "preshared_key"
        "private_key"
        ''^wireless\..*\.key''
      ];
    };

    uciKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = cfg.uciEncryptedKeys ++ [
        ''^network\.wg''
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    files.file."etc/uci-defaults/99-sops".source =
      pkgs.runCommand "files-etc-uci-defaults-99-sops" { preferLocalBuild = true; }
        ''
          grep -vE '^sops_|=ENC\[' ${cfg.file} | sed -e '1i uci batch <<EOF' -e 's/^/set /' -e '$a commit\nEOF' > $out
        '';

    sops.apply = pkgs.writeShellScriptBin "openwrt-sops-apply" ''
      set -euo pipefail

      file=${cfg.file}
      args=(${cfg.hostname})
      if [ "$#" -gt 0 ]; then
        args=("$@")
      fi

      ${lib.getExe pkgs.sops} decrypt "$file" | sed -e 's/^/set /' -e '$a changes' \
        | ssh "''${args[@]}" 'echo; echo "uci changes:"; uci batch'
      ssh "''${args[@]}" '
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

      ssh "''${args[@]}" 'uci show' | grep -E "${lib.concatStringsSep "|" cfg.uciKeys}" | LC_ALL=C sort -t'=' -k1,1 -k2,2r \
        | ${lib.getExe pkgs.sops} encrypt --encrypted-regex "${lib.concatStringsSep "|" cfg.uciEncryptedKeys}" \
          --filename-override .env --input-type dotenv > "${config.uci.system.hostname}.env" 
    '';
  };
}
