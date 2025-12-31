{ runCommand, ... }:

let
  bin = ./bin;
in

runCommand "scripts" { preferLocalBuild = true; } ''
  mkdir -p $out/bin
  cp ${bin}/* $out/bin
  chmod +x $out/bin/*
''
