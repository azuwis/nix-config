{ path }:
let
  inherit (pkgs) lib;
  pkgs = import ../default.nix { };
  package = lib.attrByPath (lib.splitString "." path) null pkgs;
  render =
    meta:
    let
      entry = name: lib.optional (builtins.hasAttr name meta) "${name}: ${meta.${name}}";
    in
    lib.concatStringsSep "\n" (
      lib.concatLists [
        (entry "homepage")
        (entry "description")
        (entry "changelog")
      ]
    );
  info = render package.meta;
in
info
