{ pkgs }:

let
  inputs = import ../inputs;
  treefmt-nix = import inputs.treefmt-nix.outPath;
in

treefmt-nix.mkWrapper pkgs {
  projectRootFile = "shell.nix";
  settings.global.excludes = [ "hosts/hardware-*.nix" ];

  programs.nixfmt.enable = true;
  # nixfmt-rfc-style renamed to nixfmt, and become an alias, but treefmt-nix still use it
  # https://github.com/numtide/treefmt-nix/blob/5b4ee75aeefd1e2d5a1cc43cf6ba65eba75e83e4/programs/nixfmt.nix#L18
  programs.nixfmt.package = pkgs.nixfmt;

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
