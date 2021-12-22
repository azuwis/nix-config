{ config, lib, pkgs, ... }:

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
      if [ ! -e "${config.user.home}/.termux/font.ttf" ]; then
        $DRY_RUN_CMD "${pkgs.curl}/bin/curl" -fsSL -o "${config.user.home}/.termux/font.ttf" 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/Ligatures/Regular/complete/JetBrains%20Mono%20Regular%20Nerd%20Font%20Complete%20Mono.ttf'
      fi
  '';
}
