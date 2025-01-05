{ path }:

let
  inherit (pkgs) lib;
  pkgs = import ../. { };
  package = lib.attrByPath (lib.splitString "." path) null pkgs;
  render =
    package:
    let
      inherit (package) meta;
      entry =
        cond: heading: value:
        lib.optional cond "${heading}: ${value}";
    in
    lib.concatStringsSep "\n" (
      lib.concatLists [
        (entry (meta ? homepage) "Homepage" meta.homepage)
        (entry (meta ? description) "Description" meta.description)
        (entry (meta ? changelog) "Changelog" meta.changelog)
        (entry (package.src ? gitRepoUrl) "Git" package.src.gitRepoUrl)
        [ "" ]
      ]
    );
  info = render package;
in
info
