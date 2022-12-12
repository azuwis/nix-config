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
      };
      keys.normal = {
        space.space = "file_picker";
      };
      theme = "nord";
    };
  };
}
