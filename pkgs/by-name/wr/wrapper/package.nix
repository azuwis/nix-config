{
  lib,
  runCommand,
  makeWrapper,
}:

{
  package,
  env ? { },
}:

runCommand package.name
  {
    inherit (package) pname version meta;

    nativeBuildInputs = [
      makeWrapper
    ];
  }
  ''
    mkdir -p "$out"
    for file in "${package}"/*; do
      basename=$(basename "$file")
      if [ "$basename" != "bin" ]; then
        ln -sv "$file" "$out/"
      fi
    done
    exe="${lib.getExe package}"
    makeWrapper "$exe" "$out/bin/$(basename "$exe")" \
      ${lib.concatMapAttrsStringSep " " (name: value: "--set ${name} ${value}") env}
  ''
