{
  config,
  lib,
  pkgs,
  ...
}:

let
  termuxConfig = ''
    bell-character=beep
  '';
in

{
  build.activation.termux = ''
    $VERBOSE_ECHO "Config Termux..."
    $DRY_RUN_CMD mkdir -p "${config.user.home}/.termux"
    $DRY_RUN_CMD echo "${termuxConfig}" > "${config.user.home}/.termux/termux.properties"
  '';

  terminal.font = "${pkgs.nerd-fonts.jetbrains-mono}/share/fonts/truetype/NerdFonts/JetBrainsMono/JetBrainsMonoNerdFont-Regular.ttf";
}
