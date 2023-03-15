{ config, inputs, lib, pkgs, ... }:

{
  environment.etc = lib.mapAttrs'
    (name: value: { name = "nix/inputs/${name}"; value = { source = value.outPath; }; })
    inputs;
  nix.nixPath = [ "/etc/nix/inputs" ];
  nix.registry = builtins.mapAttrs
    (name: value: { flake = value; })
    inputs;
}
