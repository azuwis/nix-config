{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf mkMerge;
  cfg = config.my.steam;
in
{
  options.my.steam = {
    enable = mkEnableOption "steam";
    nvidia-offload = mkEnableOption "nvidia-offload";
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
        args = [ "--rt" ];
        env = {
          # ENABLE_GAMESCOPE_WSI = "0";
          # WLR_DRM_DEVICES = "/dev/dri/card0";
        };
      };

      programs.steam = {
        enable = true;
        gamescopeSession = {
          enable = true;
        };
        package = pkgs.steam.override {
          extraPreBwrapCmds = ''
            install -m 0755 -d "$HOME/steam/$USER"
          '';
          extraBwrapArgs = [
            ''--unshare-all --share-net''
            ''--bind "$HOME/steam" /home''
            ''--tmpfs /run/user''
            ''--bind-try "$XDG_RUNTIME_DIR/bus" "$XDG_RUNTIME_DIR/bus"''
            ''--bind-try "$XDG_RUNTIME_DIR/gamescope-0" "$XDG_RUNTIME_DIR/gamescope-0"''
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
  ]);
}
