{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem.treefmt = {
    projectRootFile = "flake.nix";
    programs.nixfmt.enable = true;
    programs.stylua.enable = true;
    settings.global.excludes = [ "hosts/hardware-*.nix" ];
  };
}
