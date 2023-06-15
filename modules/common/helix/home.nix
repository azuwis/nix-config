{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.helix;
in
{
  options.my.helix = {
    enable = mkEnableOption (mdDoc "helix");
  };

  config = mkIf cfg.enable {
    # home.sessionVariables.EDITOR = "hx";
    programs.helix = {
      enable = true;
      package = with pkgs; runCommand "helix" { buildInputs = [ makeWrapper ]; } ''
        makeWrapper ${helix}/bin/hx $out/bin/hx \
          --suffix PATH : "${lib.makeBinPath [
            gopls
            nil
            terraform-ls
            yaml-language-server
          ]}"
      '';
      settings = {
        editor = {
          bufferline = "multiple";
          color-modes = true;
          cursor-shape.insert = "bar";
          indent-guides = {
            render = true;
            character = "▏";
            skip-levels = 1;
          };
          true-color = true;
        };
        keys.normal = {
          space.q = ":quit";
          space.space = "file_picker";
        };
        theme = "mynord";
      };
      themes = {
        mynord = {
          inherits = "nord";
          "ui.cursor.primary" = { bg = "#6d7b99"; };
          "ui.virtual.indent-guide" = "nord1";
        };
      };
    };
  };
}
