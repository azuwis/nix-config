{ inputs, ... }: {
  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  perSystem.treefmt = {
    projectRootFile = "flake.nix";
    programs.nixfmt-rfc-style.enable = true;
    programs.stylua.enable = true;
  };
}
