{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.sops;

  sopsDecrypt = ''
    decrypt() {
      file="$1"
      if [ -r /etc/ssh/ssh_host_ed25519_key.pub ] && grep -q "$(cut -d' ' -f 1-2 /etc/ssh/ssh_host_ed25519_key.pub)" "$file"; then
        sudo SOPS_AGE_SSH_PRIVATE_KEY_FILE=/etc/ssh/ssh_host_ed25519_key sops decrypt "$file"
      else
        sops decrypt "$file"
      fi
    }

    filter_encrypted() {
      jq --arg regex '^(${lib.concatStringsSep "|" cfg.sopsEncryptedRegex})$' '
    map_values(
      map_values(
        with_entries(select(.key == ".type" or (.key | test($regex))))
        | select(any(keys_unsorted[]; test($regex)))
      ) | select(length > 0)
    ) | select(length > 0)
    '
    }
  '';
in

{
  options.sops = {
    enable = lib.mkEnableOption "sops";

    apply = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
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
      ''^dhcp\.@dnsmasq\[0\]\.(address|rebind_domain|server)$''
      ''^dhcp\.ipset_''
      ''^etherwake\.@target''
      ''^firewall\.(ipset_|redirect_|rule_)''
      ''^network\.(lan|wan)\.(netmask|ipaddr|netmask|proto|username)$''
      ''^network\.(globals\.|wg|rule_|route_)''
      ''^shadowsocks-libev\.''
      ''^wireless\.default_radio[0-9]\.(ssid|encryption|disabled|key|hidden)$''
      ''^wireless\.radio[0-9]\.(channel|htmode|disabled|country)$''
    ];

    sops.apply = pkgs.writeShellScriptBin "openwrt-sops-apply" ''
      set -euo pipefail

      PATH="${
        lib.makeBinPath (
          with pkgs;
          [
            sops
          ]
        )
      }:$PATH"

      file="${config.builder.hostname}.json"
      args=(${config.builder.hostname})
      if [ "$#" -gt 0 ]; then
        args=("$@")
      fi

      ${sopsDecrypt}

      ssh "''${args[@]}" 'cat >/tmp/uci-import.js' <${../uci/uci-import.js}
      ssh "''${args[@]}" 'ucode /tmp/uci-import.js' <<'EOF'
      ${builtins.toJSON config.uci}
      EOF
      decrypt "$file" | ssh "''${args[@]}" 'ucode /tmp/uci-import.js'
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

      PATH="${
        lib.makeBinPath (
          with pkgs;
          [
            sops
          ]
        )
      }:$PATH"

      args=(${config.builder.hostname})
      if [ "$#" -gt 0 ]; then
        args=("$@")
      fi

      ssh "''${args[@]}" 'ucode - "${lib.concatStringsSep "|" cfg.uciKeys}"' <${./uci-export.js} \
        | sops encrypt --encrypted-regex "^(${lib.concatStringsSep "|" cfg.sopsEncryptedRegex})$" \
          --filename-override "${config.builder.hostname}.json" \
          --output "${config.builder.hostname}.json"

      ssh "''${args[@]}" 'ucode - ".*"' <${./uci-export.js} \
        | sops encrypt --encrypted-regex "^(${lib.concatStringsSep "|" cfg.sopsEncryptedRegex})$" \
          --filename-override "${config.builder.hostname}-full.json" \
          --output "${config.builder.hostname}-full.json"
    '';

    sops.sysupgrade = pkgs.writeShellScriptBin "openwrt-sops-sysupgrade" ''
      set -euo pipefail

      PATH="${
        lib.makeBinPath (
          with pkgs;
          [
            jq
            sops
          ]
        )
      }:$PATH"

      file=${inputs.my.outPath + "/${config.builder.hostname}.json"}
      args=(${config.builder.hostname})
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

      ${sopsDecrypt}

      ssh "''${args[@]}" 'echo "uci-import <<\EOF" >/tmp/sysupgrade/config/etc/uci-defaults/95-sops-enc'
      decrypt "$file" | filter_encrypted | ssh "''${args[@]}" 'cat >>/tmp/sysupgrade/config/etc/uci-defaults/95-sops-enc'
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

    uci = lib.filterAttrsRecursive (
      name: value: name != "sops" && !(builtins.isString value && lib.hasPrefix "ENC[" value)
    ) (lib.importJSON (inputs.my.outPath + "/${config.builder.hostname}.json"));
  };
}
