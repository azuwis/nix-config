let
  inputs = import ../inputs;
  pkgs = import ../pkgs { };
  devshell = import inputs.devshell.outPath { nixpkgs = pkgs; };
  treefmt-nix = import inputs.treefmt-nix.outPath;

  treefmt = treefmt-nix.mkWrapper pkgs {
    # For `nixpkgs.config.allowAliases = false`
    package = pkgs.treefmt2;
    projectRootFile = "flake.nix";
    settings.global.excludes = [ "hosts/hardware-*.nix" ];

    programs.nixfmt.enable = true;

    programs.shfmt = {
      enable = true;
      # Use settings in .editorconfig
      indent_size = null;
    };
    settings.formatter.shfmt = {
      includes = [
        ".githooks/*"
        "pkgs/by-name/sc/scripts/bin/*"
        "scripts/os"
        "scripts/update"
      ];
    };

    programs.stylua.enable = true;

    programs.yamlfmt.enable = true;
  };
in

devshell.mkShell {
  packages = [
    treefmt
  ];
}
