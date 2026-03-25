{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.uci;
in

{
  options.uci = lib.mkOption {
    default = { };
    type =
      with lib.types;
      attrsOf (
        attrsOf (
          (attrsOf (oneOf [
            str
            (listOf str)
          ]))
        )
      );
  };

  config = {
    files.file = {
      # radio0 and radio1 are not consistent between fresh install, swap them
      # if needed to make sure radio0 is always 2g
      "etc/uci-defaults/90-wireless-order".text = ''
        if [ "$(uci -q get wireless.radio1.band)" = 2g ]; then
          uci batch <<'EOF'
        set wireless.default_radio0.device=radio1
        set wireless.default_radio1.device=radio0
        rename wireless.default_radio0=default_radio9
        rename wireless.default_radio1=default_radio0
        rename wireless.default_radio9=default_radio1
        rename wireless.radio0=radio9
        rename wireless.radio1=radio0
        rename wireless.radio9=radio1
        commit wireless
        EOF
        fi
      '';
      "etc/uci-defaults/92-uci-import".text = ''
        uci-import <<'EOF'
        ${builtins.toJSON cfg}
        EOF
        uci commit
      '';
      "etc/uci-defaults/99-chmod-etc-config".text = ''
        chmod 600 /etc/config/*
      '';
      "usr/bin/uci-import".source = ./uci-import.js;
    };

    uci.system."@system[0]".hostname = config.builder.hostname;
  };
}
