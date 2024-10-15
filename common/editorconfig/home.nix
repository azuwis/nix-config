{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.editorconfig;
in
{
  options.my.editorconfig = {
    enable = mkEnableOption "editorconfig";
  };

  config = mkIf cfg.enable {
    editorconfig.enable = true;
    editorconfig.settings = {
      # https://github.com/LazyVim/LazyVim/blob/main/stylua.toml
      "*.lua" = {
        indent_style = "space";
        indent_size = 2;
        max_line_length = 120;
        sort_requires = true;
      };
    };
    # `toINIWithGlobalSection` will escape `[shell]` to `\[shell\]`, use home.file.<name>.txt here
    home.file.".editorconfig".text = ''
      # man shfmt
      [[shell]]
      indent_style = space
      indent_size = 2
      max_line_length = 120
    '';
  };
}
