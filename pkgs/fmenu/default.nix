{ pkgs, ... }:

let bin = ./bin;

in

pkgs.runCommand "fmenu" { } ''
  mkdir -p $out/bin
  cp ${bin}/* $out/bin
  chmod +x $out/bin/*
''
