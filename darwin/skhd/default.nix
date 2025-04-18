{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.skhd =
    let
      mkMenu = command: "kitty --single-instance --title Fzf ${command}";
      # ''set -- -o window.dimensions.columns=50 -o window.dimensions.lines=6 -o window.position.x=1000 -o window.position.y=48 --title=Fzf --command ${command}; alacritty msg create-window "$@" || alacritty "$@"'';
    in
    {
      enable = true;
      # lalt - return : alacritty msg create-window || SHELL=/run/current-system/sw/bin/zsh open -n -a ${pkgs.alacritty}/Applications/Alacritty.app
      skhdConfig = ''
        lalt - 1 : yabai -m space --focus 1
        lalt - 2 : yabai -m space --focus 2
        lalt - 3 : yabai -m space --focus 3
        lalt - 4 : yabai -m space --focus 4
        lalt - 5 : yabai -m space --focus 5
        lalt - 6 : yabai -m space --focus 6
        lalt - 7 : yabai -m space --focus 7
        lalt - 8 : yabai -m space --focus 8
        lalt - 9 : yabai -m space --focus 9
        lalt - 0 : yabai -m space --focus 10
        lshift + lalt - n : yabai -m space --create
        lshift + lalt - m : yabai -m space --destroy
        lshift + lalt - 1 : yabai -m window --space 1
        lshift + lalt - 2 : yabai -m window --space 2
        lshift + lalt - 3 : yabai -m window --space 3
        lshift + lalt - 4 : yabai -m window --space 4
        lshift + lalt - 5 : yabai -m window --space 5
        lshift + lalt - 6 : yabai -m window --space 6
        lshift + lalt - 7 : yabai -m window --space 7
        lshift + lalt - 8 : yabai -m window --space 8
        lshift + lalt - 9 : yabai -m window --space 9
        lshift + lalt - 0 : yabai -m window --space 10
        lalt - l : yabai -m window --focus east || yabai -m window --focus stack.next || yabai -m window --focus stack.first
        lalt - j : yabai -m window --focus south
        lalt - h : yabai -m window --focus west || yabai -m window --focus stack.prev || yabai -m window --focus stack.last
        lalt - k : yabai -m window --focus north
        lalt - d : ${mkMenu "appfzf"}
        lalt - q : yabai -m window --close
        lshift + lalt - l : yabai -m window --swap east
        lshift + lalt - j : yabai -m window --swap south
        lshift + lalt - h : yabai -m window --swap west
        lshift + lalt - k : yabai -m window --swap north
        lshift + lalt - p : ${mkMenu "passfzf"}
        lshift + lalt - 0x29 : yabai -m window --toggle split
        lalt - c : yabai -m window --toggle float && yabai -m window --grid 6:6:1:1:4:4
        lalt - f : yabai -m window --toggle zoom-fullscreen; yabai -m window --grid 1:1:0:0:1:1; \
                   yabai -m query --windows space,has-fullscreen-zoom --window mouse | jq -r '[.space, ."has-fullscreen-zoom"] | @sh' | \
                   { read -r index fullscreen; if [ "$fullscreen" = true ]; then icon="↑"; padding=14; else icon="$index"; padding=16; fi; \
                   sketchybar -m --set "space$index" icon="$icon" label_padding_right="$padding"; }
        lalt - m : yabai -m window --minimize
        lalt - t : yabai -m window --toggle float
        lalt - tab : yabai -m space --focus recent
        lalt - w : yabai -m space --layout stack
        lalt - e : yabai -m space --layout bsp
        lalt - s : yabai -m space --layout float
        lalt - return : SHELL=/run/current-system/sw/bin/zsh kitty --single-instance
      '';
    };

  launchd.user.agents.skhd = {
    environment = {
      NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
      SHELL = "/bin/dash";
    };
    serviceConfig.WorkingDirectory = config.users.users.${config.my.user}.home;
  };

  launchd.user.agents.skhd.path = lib.mkForce [ config.my.systemPath ];

  # launchd.user.agents.skhd.serviceConfig = {
  #   StandardErrorPath = "/tmp/skhd.log";
  #   StandardOutPath = "/tmp/skhd.log";
  # };

  system.activationScripts.preActivation.text = ''
    ${pkgs.sqlite}/bin/sqlite3 '/Library/Application Support/com.apple.TCC/TCC.db' \
      "INSERT or REPLACE INTO access(service,client,client_type,auth_value,auth_reason,auth_version) VALUES('kTCCServiceAccessibility','${pkgs.skhd}/bin/skhd',1,2,4,1);"
  '';
  system.activationScripts.postActivation.text = ''
    ${pkgs.sqlite}/bin/sqlite3 '/Library/Application Support/com.apple.TCC/TCC.db' \
      "DELETE from access where client_type = 1 and client != '${pkgs.skhd}/bin/skhd' and client like '%/bin/skhd';"
  '';
}
