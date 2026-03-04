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
      default = "${inputs.my.outPath}/${config.uci.system."@system[0]".hostname}.json";
    };

    hostname = lib.mkOption {
      type = lib.types.str;
      default = config.uci.system."@system[0]".hostname;
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

    sysupgrade = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
    };

    uciKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    sops.uciKeys = [
      "password"
      "preshared_key"
      "private_key"
      ''^etherwake\.@target''
      ''^firewall\.(redirect_|rule_)''
      ''^network\.(lan|wan)\.(netmask|ipaddr|netmask|proto|username)$''
      ''^network\.wg''
      ''^shadowsocks-libev\.''
      ''^wireless\.default_radio[0-9]\.(ssid|encryption|key|hidden)$''
      ''^wireless\.radio[0-9]\.(channel|htmode|disabled|country)$''
    ];

    files.file."usr/bin/uci-import".source = ./uci-import.js;
    files.file."etc/uci-defaults/95-sops".source =
      pkgs.runCommand "files-etc-uci-defaults-95-sops" { preferLocalBuild = true; }
        ''
          echo "uci-import <<'EOF'" >$out
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

      PATH="${lib.makeBinPath [ pkgs.sops ]}:$PATH"

      file=${cfg.file}
      args=(${cfg.hostname})
      if [ "$#" -gt 0 ]; then
        args=("$@")
      fi

      decrypt() {
        if [ -r /etc/ssh/ssh_host_ed25519_key.pub ] && grep -q "$(cut -d' ' -f 1-2 /etc/ssh/ssh_host_ed25519_key.pub)" "$file"; then
          sudo SOPS_AGE_SSH_PRIVATE_KEY_FILE=/etc/ssh/ssh_host_ed25519_key sops decrypt "$file"
        else
          sops decrypt "$file"
        fi
      }

      ssh "''${args[@]}" 'cat >/tmp/uci-import.js' <${./uci-import.js}
      decrypt | ssh "''${args[@]}" 'ucode /tmp/uci-import.js'
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
          --filename-override "${config.uci.system."@system[0]".hostname}.json" \
          --output "${config.uci.system."@system[0]".hostname}.json"

      ssh "''${args[@]}" 'ucode - ".*"' <${./uci-export.js} \
        | ${lib.getExe pkgs.sops} encrypt --encrypted-regex "^(${lib.concatStringsSep "|" cfg.sopsEncryptedRegex})$" \
          --filename-override "${config.uci.system."@system[0]".hostname}-full.json" \
          --output "${config.uci.system."@system[0]".hostname}-full.json"
    '';

    sops.sysupgrade = pkgs.writeShellScriptBin "openwrt-sops-sysupgrade" ''
      set -euo pipefail

      PATH="${
        lib.makeBinPath [
          pkgs.jq
          pkgs.sops
        ]
      }:$PATH"

      file=${cfg.file}
      args=(${cfg.hostname})
      if [ "$#" -gt 0 ]; then
        args=("$@")
      fi

      ssh "''${args[@]}" '
      rm -rf /tmp/sysupgrade
      mkdir -p /tmp/sysupgrade/config/etc/dropbear /tmp/sysupgrade/config/etc/uci-defaults
      cp /etc/dropbear/dropbear_* /tmp/sysupgrade/config/etc/dropbear/
      '

      images=("${config.image}"/openwrt-*-sysupgrade.bin)
      image=''${images[0]}
      cat "$image" | ssh "''${args[@]}" 'cat >/tmp/sysupgrade/sysupgrade.bin'

      decrypt() {
        if [ -r /etc/ssh/ssh_host_ed25519_key.pub ] && grep -q "$(cut -d' ' -f 1-2 /etc/ssh/ssh_host_ed25519_key.pub)" "$file"; then
          sudo SOPS_AGE_SSH_PRIVATE_KEY_FILE=/etc/ssh/ssh_host_ed25519_key sops decrypt "$file"
        else
          sops decrypt "$file"
        fi
      }

      ssh "''${args[@]}" 'echo "uci-import <<\EOF" >/tmp/sysupgrade/config/etc/uci-defaults/95-sops-enc'
      decrypt | jq --arg regex "$(jq -r '.sops.encrypted_regex' "$file")" '
      del(.sops) | map_values(
        map_values(
          with_entries(select(.key == ".type" or (.key | test($regex))))
          | select(any(keys_unsorted[]; test($regex)))
        ) | select(length > 0)
      ) | select(length > 0)
      ' | ssh "''${args[@]}" 'cat >>/tmp/sysupgrade/config/etc/uci-defaults/95-sops-enc'
      ssh "''${args[@]}" '
      echo "EOF" >>/tmp/sysupgrade/config/etc/uci-defaults/95-sops-enc
      echo "uci commit" >>/tmp/sysupgrade/config/etc/uci-defaults/95-sops-enc
      '

      ssh "''${args[@]}" '
      tar -czf /tmp/sysupgrade/config.tar.gz -C /tmp/sysupgrade/config etc
      sysupgrade -f /tmp/sysupgrade/config.tar.gz --test /tmp/sysupgrade/sysupgrade.bin
      '

      ssh "''${args[@]}" '
      echo -n "Sysupgrade?[yN]"
      read -r answer
      if [ -n "$answer" ] && [ "$answer" == "Y" ]; then
        sysupgrade -f /tmp/sysupgrade/config.tar.gz -n /tmp/sysupgrade/sysupgrade.bin
      fi
      '
    '';
  };
}
