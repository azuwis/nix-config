{
  all ? null,
  commit ? null,
  list-package ? null,
  max-workers ? null,
  output-json ? null,
  package ? null,
  skip-prompt ? "true",
}:

let
  inherit (pkgs) lib;
  pkgs = import ../default.nix { };
  nixpkgs = pkgs.inputs.nixpkgs.outPath;

  getPosition = package: (builtins.unsafeGetAttrPos "src" package).file or package.meta.position;
  pkgHasPrefix = prefix: package: lib.hasPrefix prefix (getPosition package);

  allPackages =
    let
      pkgsWithoutOverlay = import nixpkgs { };
      byNameAttrs = import "${nixpkgs}/pkgs/top-level/by-name-overlay.nix" ../pkgs/by-name null null;
      topLevelAttrs = lib.composeManyExtensions (import ../overlays { inherit (pkgs) inputs; }) null null;
      topLevelPackages = builtins.mapAttrs (
        name: _:
        lib.warnIf (
          builtins.hasAttr name pkgsWithoutOverlay
          && builtins.hasAttr name byNameAttrs
          && name != "_internalCallByNamePackageFile"
        ) "pkgs.${name} already exists" pkgs.${name}
      ) topLevelAttrs;
      mkPkgSet =
        pkgSetName: directory:
        lib.mapAttrs'
          (
            name: value:
            lib.nameValuePair ("${pkgSetName}." + name) (
              lib.warnIf (builtins.hasAttr name
                pkgsWithoutOverlay.${pkgSetName}
              ) "pkgs.${pkgSetName}.${name} already exists" pkgs.${pkgSetName}.${name}
            )
          )
          (
            lib.packagesFromDirectoryRecursive {
              callPackage = null;
              inherit directory;
            }
          );
      luaPackages = mkPkgSet "luaPackages" ../pkgs/lua;
      python3Packages = mkPkgSet "python3Packages" ../pkgs/python;
      vimPackages = mkPkgSet "vimPlugins" ../pkgs/vim;
    in
    lib.filterAttrs
      (
        _: value:
        lib.isDerivation value && value ? updateScript && pkgHasPrefix (builtins.toString ../.) value
      )
      (
        topLevelPackages
        // lib.optionalAttrs (topLevelAttrs ? lua) luaPackages
        // lib.optionalAttrs (topLevelAttrs ? python3) python3Packages
        // lib.optionalAttrs (topLevelAttrs ? vimPlugins) vimPackages
      );

  packageByName =
    path: pkgs:
    let
      package = if builtins.hasAttr path pkgs then pkgs.${path} else null;
    in
    if package == null then
      builtins.throw "Package with an attribute name `${path}` does not exist."
    else
      {
        attrPath = path;
        inherit package;
      };

  packages =
    if all == "true" then
      lib.mapAttrsToList (attrPath: package: { inherit attrPath package; }) (
        lib.filterAttrs (_: value: !(value ? enable && value.enable == false)) allPackages
      )
    else if package != null then
      [ (packageByName package allPackages) ]
    else
      builtins.throw "No arguments provided.";

  packageData =
    { package, attrPath }:
    {
      name = package.name;
      pname = lib.getName package;
      oldVersion = lib.getVersion package;
      updateScript = map builtins.toString (
        lib.toList (package.updateScript.command or package.updateScript)
      );
      supportedFeatures = package.updateScript.supportedFeatures or [ ];
      attrPath = package.updateScript.attrPath or attrPath;
    };

  packagesJson = pkgs.writeText "packages.json" (builtins.toJSON (map packageData packages));

  optionalArgs =
    [ "--keep-going" ]
    ++ lib.optional (max-workers != null) "--max-workers=${max-workers}"
    ++ lib.optional (commit == "true") "--commit"
    ++ lib.optional (skip-prompt == "true") "--skip-prompt";

  args = [ packagesJson ] ++ optionalArgs;

in
pkgs.stdenv.mkDerivation {
  name = "update-script";
  shellHook =
    ''
      unset shellHook # do not contaminate nested shells
      unset TZ # retain git commit timezone
    ''
    + (
      if (output-json == "true") then
        ''
          exec cat "${packagesJson}"
        ''
      else if (list-package == "true") then
        ''
          exec ${pkgs.jq}/bin/jq -r '.[].attrPath' "${packagesJson}"
        ''
      else
        ''
          exec ${pkgs.python3.interpreter} "${nixpkgs}/maintainers/scripts/update.py" ${builtins.concatStringsSep " " args}
        ''
    );
}
