{ inputs, ... }: {
  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  perSystem.treefmt = {
    projectRootFile = "flake.nix";
    programs.nixpkgs-fmt.enable = true;
    programs.stylua.enable = true;
  };
}
