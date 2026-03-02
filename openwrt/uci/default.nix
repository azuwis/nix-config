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
    files.file =
      lib.mapAttrs' (
        name: attrs:
        let
          uciList = lib.collect lib.isString (
            lib.mapAttrsRecursive (
              path: value:
              let
                pathStr =
                  # XXX: Depend on .type is the first option of a section
                  if lib.last path == ".type" then
                    lib.concatStringsSep "." (lib.init path)
                  else
                    lib.concatStringsSep "." path;
              in
              if lib.isList value then
                lib.concatMapStringsSep "\n" (
                  x: "del_list ${name}.${pathStr}='${toString x}'\nadd_list ${name}.${pathStr}='${toString x}'"
                ) value
              else if value == "-" then
                "delete ${name}.${pathStr}"
              else
                "set ${name}.${pathStr}='${toString value}'"
            ) attrs
          );
        in
        lib.nameValuePair "etc/uci-defaults/92-${name}" {
          text = ''
            uci batch <<'EOF'
            ${lib.concatStringsSep "\n" uciList}
            commit ${name}
            EOF
          '';
        }
      ) cfg
      // {
        # radio0 and radio1 are not consistent between fresh install, swap them
        # to make sure radio0 is always 2g
        "etc/uci-defaults/90-wireless-order".text = ''
          if [ "$(uci get wireless.radio1.band)" = 2g ]; then
            uci batch <<'EOF'
            set wireless.default_radio0.device=radio1
            set wireless.default_radio1.device=radio0
            rename wireless.default_radio0=default_radio9
            rename wireless.default_radio1=default_radio0
            rename wireless.default_radio9=default_radio1
            rename wireless.radio0=radio9
            rename wireless.radio1=radio0
            rename wireless.radio9=radio1
          EOF
          fi
        '';
        "etc/uci-defaults/99-chmod-etc-config".text = ''
          chmod 600 /etc/config/*
        '';
      };
  };
}
