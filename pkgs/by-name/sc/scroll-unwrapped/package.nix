{
  lib,
  stdenv,
  systemd,
  sway-unwrapped,
  wlroots_0_19,
  replaceVars,
  swaybg,
  lua5_4,
  # Used by the NixOS module:
  isNixOS ? false,
  enableXWayland ? true,
  systemdSupport ? lib.meta.availableOn stdenv.hostPlatform systemd,
  trayEnabled ? systemdSupport,
}:

(sway-unwrapped.override {
  inherit
    isNixOS
    enableXWayland
    systemdSupport
    trayEnabled
    ;
  wlroots = wlroots_0_19;
}).overrideAttrs
  (
    finalAttrs: prevAttrs: {
      pname = "scroll-unwrapped";
      version = "1.11.6";

      src = prevAttrs.src.override {
        owner = "dawsers";
        repo = "scroll";
        hash = "sha256-BHp0mU9Iaj/Hbuxzp83WHsuiHMvNujXcdE5Rtjk9azs=";
      };

      patches = [
        ./load-configuration-from-etc.patch

        (replaceVars ./fix-paths.patch {
          inherit swaybg;
        })
      ]
      ++ lib.optionals finalAttrs.isNixOS [
        # Use /run/current-system/sw/share and /etc instead of /nix/store
        # references:
        ./scroll-config-nixos-paths.patch
      ];

      buildInputs = prevAttrs.buildInputs ++ [ lua5_4 ];

      meta = {
        description = "I3-compatible Wayland compositor (sway) with a PaperWM layout like niri or hyprscroller";
        homepage = "https://github.com/dawsers/scroll";
        changelog = "https://github.com/dawsers/scroll/releases/tag/${finalAttrs.version}";
        license = lib.licenses.mit;
        platforms = lib.platforms.linux;
        maintainers = with lib.maintainers; [
          azuwis
        ];
        mainProgram = "scroll";
      };
    }
  )
