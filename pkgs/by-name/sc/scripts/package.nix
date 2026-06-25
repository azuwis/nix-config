{ runCommand, ... }:

let
  bin = ./bin;
  zsh = ./zsh;
in

runCommand "scripts" { preferLocalBuild = true; } ''
  mkdir -p $out/bin $out/share/zsh/site-functions
  cp ${bin}/* $out/bin
  chmod +x $out/bin/*
  cp ${zsh}/_os $out/share/zsh/site-functions/_os
''
