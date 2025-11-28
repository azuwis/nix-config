let
  filterAttrs =
    pred: set:
    removeAttrs set (builtins.filter (name: !pred name set.${name}) (builtins.attrNames set));
  getPaths =
    file: root:
    builtins.filter builtins.pathExists (
      map (dir: root + "/${dir}/${file}") (
        builtins.attrNames (filterAttrs (name: type: type == "directory") (builtins.readDir root))
      )
    );
in
{
  inherit getPaths;
  getModules = builtins.concatMap (getPaths "default.nix");
  getHmModules = builtins.concatMap (getPaths "home.nix");
}
