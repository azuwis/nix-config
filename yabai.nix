{ config, pkgs, ... }:

{
  nixpkgs.overlays = [( self: super: {
    yabai = super.yabai.overrideAttrs (o: rec {
      version = "3.3.10";
      src = builtins.fetchTarball {
        url = "https://github.com/azuwis/yabai/releases/download/v${version}/yabai-v${version}.tar.gz";
        sha256 = "0gbigxgs5n6ack56sb24y08qqyaygq8nwqdlmqqbrwdq02yps3dv";
      };

      installPhase = ''
        mkdir -p $out/bin
        mkdir -p $out/share/man/man1/
        cp ./archive/bin/yabai $out/bin/yabai
        cp ./archive/doc/yabai.1 $out/share/man/man1/yabai.1
      '';
    });
  })];

  environment.etc."sudoers.d/yabai".text = ''
    ${config.my.user} ALL = (root) NOPASSWD: ${pkgs.yabai}/bin/yabai --load-sa
  '';

  launchd.user.agents.yabai.serviceConfig = {
    StandardErrorPath = "/tmp/yabai.log";
    StandardOutPath = "/tmp/yabai.log";
  };

  services.yabai = {
    enable = true;
    package = pkgs.yabai;
    config = {
      window_gap = 3;
    };
    extraConfig = ''
      sudo ${pkgs.yabai}/bin/yabai --load-sa
      yabai -m signal --add event=dock_did_restart action="sudo ${pkgs.yabai}/bin/yabai --load-sa"
    '';
  };

  services.skhd = {
    enable = true;
    skhdConfig = ''
      # float / unfloat window and center on screen
      alt - t : yabai -m window --toggle float;\
                yabai -m window --grid 4:4:1:1:2:2
      # make floating window fill screen
      shift + alt - up     : yabai -m window --grid 1:1:0:0:1:1
    '';
  };
}
