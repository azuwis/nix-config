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
      "etc/uci-defaults/92-uci-import".text = ''
        uci-import <<'EOF'
        ${builtins.toJSON cfg}
        EOF
        uci commit
      '';
      "usr/bin/uci-import".source = ./uci-import.js;
    };

    uci.system."@system[0]".hostname = config.builder.hostname;
  };
}
