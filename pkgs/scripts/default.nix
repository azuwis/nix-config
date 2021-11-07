{ pkgs, ... }:

let bin = ./bin;

in

pkgs.runCommand "scripts" { } ''
  mkdir -p $out/bin
  cp ${bin}/* $out/bin
  chmod +x $out/bin/*
''
