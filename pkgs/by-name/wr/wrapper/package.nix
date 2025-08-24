{
  lib,
  runCommand,
  makeWrapper,
}:

{
  package,
  env ? { },
}:

let
  hasMan = builtins.hasAttr "man" package;
  makeWrapperArgs = lib.flatten (
    lib.mapAttrsToList (name: value: [
      "--set"
      name
      value
    ]) env
  );
in

runCommand package.name
  {
    inherit (package) pname version;

    nativeBuildInputs = [
      makeWrapper
    ];

    outputs = [
      "out"
    ]
    ++ (lib.optional hasMan "man");

    meta = (package.meta or { }) // {
      outputsToInstall = [
        "out"
      ]
      ++ (lib.optional hasMan "man");
    };
  }
  (
    ''
      mkdir -p "$out"
      for file in "${package}"/*; do
        basename=$(basename "$file")
        if [ "$basename" != "bin" ]; then
          ln -sv "$file" "$out/"
        fi
      done
      exe="${lib.getExe package}"
      makeWrapper "$exe" "$out/bin/$(basename "$exe")" ${lib.escapeShellArgs makeWrapperArgs}
    ''
    + lib.optionalString hasMan ''
      ln -s ${package.man} "$man"
    ''
  )
