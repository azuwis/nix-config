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
                pathStr = lib.concatStringsSep "." path;
              in
              if lib.isList value then
                lib.concatMapStringsSep "\n" (
                  x: "del_list ${name}.${pathStr}='${toString x}'\nadd_list ${name}.${pathStr}='${toString x}'"
                ) value
              else
                "set ${name}.${pathStr}='${toString value}'"
            ) attrs
          );
        in
        lib.nameValuePair "etc/uci-defaults/90-${name}" {
          text = ''
            uci batch <<'EOF'
            ${lib.concatStringsSep "\n" uciList}
            commit ${name}
            EOF
          '';
        }
      ) cfg
      // {
        "etc/uci-defaults/99-chmod-etc-config".text = ''
          chmod 600 /etc/config/*
        '';
      };
  };
}
