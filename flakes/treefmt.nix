{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem.treefmt =
    { pkgs, ... }:
    {
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
}
