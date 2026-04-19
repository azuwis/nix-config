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
  '';
in

{
  options.sops = {
    enable = lib.mkEnableOption "sops";

    apply = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
    };

    encryptedUciKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
    };

    save = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
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
    sops.encryptedUciKeys = [
      ''\.(password|preshared_key|private_key)$''
      ''^wireless\..*\.key$''
    ];

    sops.uciKeys = [
      "password"
      "preshared_key"
      "private_key"
      ''^dhcp\.@dnsmasq\[0\]\.(address|rebind_domain|server)$''
      ''^dhcp\.dnsmasq_''
      ''^dhcp\.ipset_''
      ''^firewall\.(ipset_|redirect_|rule_)''
      ''^network\.(lan|wan)\.(netmask|ipaddr|netmask|proto|username)$''
      ''^network\.(globals\.|wg|rule_|route_)''
      ''^shadowsocks-libev\.''
      ''^wireless\.default_radio[0-9]\.(ssid|encryption|disabled|hidden)$''
      ''^wireless\.radio[0-9]\.(channel|htmode|disabled|country)$''
    ];

    sops.apply = pkgs.writeShellScriptBin "openwrt-sops-apply" ''
      set -euo pipefail

      PATH="${
        lib.makeBinPath (
          with pkgs;
          [
            sops
            remarshal
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
      toml2json "${config.builder.hostname}.toml" | ssh "''${args[@]}" 'ucode /tmp/uci-import.js'
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
            remarshal
            sops
          ]
        )
      }:$PATH"

      args=(${config.builder.hostname})
      if [ "$#" -gt 0 ]; then
        args=("$@")
      fi

      ssh "''${args[@]}" 'ucode - "${lib.concatStringsSep "|" cfg.uciKeys}" "${lib.concatStringsSep "|" cfg.encryptedUciKeys}"' <${./uci-export.js} \
        | json2toml --multiline 2 > "${config.builder.hostname}.toml"

      ssh "''${args[@]}" 'ucode - ".*" "${lib.concatStringsSep "|" cfg.encryptedUciKeys}"' <${./uci-export.js} \
        | json2toml --multiline 2 > "${config.builder.hostname}-full.toml"

      ssh "''${args[@]}" 'ucode - "${lib.concatStringsSep "|" cfg.encryptedUciKeys}"' <${./uci-export.js} \
        | sops encrypt --filename-override "${config.builder.hostname}.json" \
          --output "${config.builder.hostname}.json"
    '';

    sops.sysupgrade = pkgs.writeShellScriptBin "openwrt-sops-sysupgrade" ''
      set -euo pipefail

      PATH="${
        lib.makeBinPath (
          with pkgs;
          [
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
      decrypt "$file" | ssh "''${args[@]}" 'cat >>/tmp/sysupgrade/config/etc/uci-defaults/95-sops-enc'
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

    uci = lib.importTOML (inputs.my.outPath + "/${config.builder.hostname}.toml");
  };
}
