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
        attrsOf (oneOf [
          (oneOf [
            str
            (listOf str)
          ])
          (attrsOf (oneOf [
            str
            (listOf str)
          ]))
        ])
      );
  };

  config = {
    files.file = lib.mapAttrs' (
      name: attrs:
      let
        uciList = lib.collect lib.isString (
          lib.mapAttrsRecursive (
            path: value:
            let
              pathStr =
                if (lib.length path) == 1 then "@${name}[0].${lib.head path}" else lib.concatStringsSep "." path;
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
          uci batch <<EOF
          ${lib.concatStringsSep "\n" uciList}
          commit ${name}
          EOF
        '';
      }
    ) cfg;
  };
}
