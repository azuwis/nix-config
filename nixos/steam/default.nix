{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf mkMerge;
  cfg = config.my.steam;
in
{
  options.my.steam = {
    enable = mkEnableOption "steam";
    nvidia-offload = mkEnableOption "nvidia-offload";
    gamescope-intel-fix = mkEnableOption "gamescope-intel-fix";
  };

  config = mkIf cfg.enable (mkMerge [
    ({
      networking.networkmanager.enable = true;
      networking.useNetworkd = false;

      environment.systemPackages = with pkgs; [
        mangohud
      ];

      programs.gamescope = {
        enable = true;
        capSysNice = true;
      };

      programs.steam = {
        enable = true;
        gamescopeSession = {
          enable = true;
          args = [ "--rt" "--filter" "fsr" ];
          env = {
            # ENABLE_GAMESCOPE_WSI = "0";
            # WLR_DRM_DEVICES = "/dev/dri/card0";
          };
        };
        package = pkgs.steam.override {
          extraPreBwrapCmds = ''
            install -m 0755 -d "$HOME/steam/$USER"
          '';
          extraBwrapArgs = [
            ''--unshare-all --share-net''
            ''--bind "$HOME/steam" /home''
            ''--ro-bind "${pkgs.noto-fonts-cjk-sans}/share/fonts/opentype/noto-cjk" "/home/$USER/.fonts"''
            ''--tmpfs /run/user''
            ''--bind-try "/run/user/$UID/bus" "/run/user/$UID/bus"''
            ''--bind-try "/run/user/$UID/gamescope-0" "/run/user/$UID/gamescope-0"''
            ''--bind-try "/run/user/$UID/pulse" "/run/user/$UID/pulse"''
          ];
          extraEnv = {
            MANGOHUD = "1";
          } // lib.optionalAttrs cfg.nvidia-offload {
            __GLX_VENDOR_LIBRARY_NAME = "nvidia";
            __NV_PRIME_RENDER_OFFLOAD = "1";
            __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
            __VK_LAYER_NV_optimus = "NVIDIA_only";
          };
        };
      };

    })

    (mkIf cfg.gamescope-intel-fix {
      # https://github.com/ValveSoftware/gamescope/issues/1029
      programs.gamescope.package = pkgs.gamescope.overrideAttrs (old: {
        patches = old.patches ++ [ ./gamescope.diff ];
      });
    })
  ]);
}
