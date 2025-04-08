{ pkgs }:

let
  inputs = import ../inputs;
  treefmt-nix = import inputs.treefmt-nix.outPath;
in

treefmt-nix.mkWrapper pkgs {
  projectRootFile = "shell.nix";
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
}
