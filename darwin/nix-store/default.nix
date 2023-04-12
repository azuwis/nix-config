{ config, lib, pkgs, ... }:

{
  # https://github.com/NixOS/nix/issues/7273
  nix.settings.auto-optimise-store = false;
  launchd.daemons."nix-store-optimise".serviceConfig = {
    ProgramArguments = [
      "/bin/sh"
      "-c"
      ''
        /bin/wait4path ${pkgs.nix}/bin/nix && \
          exec ${pkgs.nix}/bin/nix --experimental-features nix-command store optimise
      ''
    ];
    StartCalendarInterval = [
      {
        Hour = 4;
        Minute = 30;
      }
    ];
    StandardErrorPath = "/var/log/nix-store.log";
    StandardOutPath = "/var/log/nix-store.log";
  };
}
