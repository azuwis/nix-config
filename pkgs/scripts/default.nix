{ runCommand, ... }:

let bin = ./bin;

in

runCommand "scripts" { } ''
  mkdir -p $out/bin
  cp ${bin}/* $out/bin
  chmod +x $out/bin/*
''
