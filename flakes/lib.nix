_:

let my = { lib, ... }: {
  genModules = root: file:
    builtins.filter builtins.pathExists
      (map (dir: root + "/${dir}/${file}")
        (lib.attrNames
          (lib.filterAttrs (name: type: type == "directory")
            (builtins.readDir root))));
};

in {
  perSystem = { lib, ... }: {
    _module.args.lib = lib.extend (final: prev: { my = my { lib = final; }; });
  };
}
