{
  lib,
  runCommand,
  makeBinaryWrapper,
  makeWrapper,
}:

{
  package,
  env ? { },
  flags ? [ ],
  wrapper ? makeWrapper,
  wrapperArgs ? [ ],
}:

let
  hasMan = builtins.hasAttr "man" package;
  makeWrapperArgs =
    lib.flatten (
      lib.mapAttrsToList (name: value: [
        "--set"
        name
        value
      ]) env
    )
    ++ (lib.flatten (
      map (f: [
        "--add-flag"
        f
      ]) flags
    ))
    ++ wrapperArgs;
in

runCommand package.name
  {
    inherit (package) pname version;

    nativeBuildInputs = [
      wrapper
    ];

    outputs = [
      "out"
    ]
    ++ (lib.optional hasMan "man");

    preferLocalBuild = true;

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
    ''
    + lib.optionalString (wrapper == makeWrapper) ''
      makeWrapper "$exe" "$out/bin/$(basename "$exe")" ${lib.escapeShellArgs makeWrapperArgs}
    ''
    + lib.optionalString (wrapper == makeBinaryWrapper) ''
      makeBinaryWrapper "$exe" "$out/bin/$(basename "$exe")" ${lib.escapeShellArgs makeWrapperArgs}
    ''
    + lib.optionalString hasMan ''
      ln -s ${package.man} "$man"
    ''
  )
