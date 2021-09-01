{ pkgs, ... }:

let bin = ./bin;

in

pkgs.runCommand "passmenu" { } ''
  mkdir -p $out/bin
  cp ${bin}/* $out/bin
  chmod +x $out/bin/*
''
