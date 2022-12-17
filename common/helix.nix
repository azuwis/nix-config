{ config, lib, pkgs, ... }:

{
  # home.sessionVariables.EDITOR = "hx";
  programs.helix = {
    enable = true;
    package = with pkgs; runCommand "helix" { buildInputs = [ makeWrapper ]; } ''
      makeWrapper ${helix}/bin/hx $out/bin/hx \
        --suffix PATH : "${lib.makeBinPath [
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
}
