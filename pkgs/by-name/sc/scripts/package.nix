{ runCommandLocal, ... }:

let
  bin = ./bin;
  zsh = ./zsh;
in

runCommandLocal "scripts" { } ''
  mkdir -p $out/bin $out/share/zsh/site-functions
  cp ${bin}/* $out/bin
  chmod +x $out/bin/*
  cp ${zsh}/_os $out/share/zsh/site-functions/_os
''
