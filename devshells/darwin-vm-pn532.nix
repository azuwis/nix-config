{ ... }:

let
  inputs = import ../inputs;
  pkgs = import ../pkgs { };
  devshell = import inputs.devshell.outPath { nixpkgs = pkgs; };

  vm-pn532 =
    let
      builder = pkgs.darwin.linux-builder.override {
        modules = [
          (
            {
              pkgs,
              ...
            }:
            {
              environment.systemPackages = with pkgs; [
                libnfc
                mfoc-hardnested
              ];
              security.sudo = {
                execWheelOnly = true;
                wheelNeedsPassword = false;
              };
              users.users.builder.extraGroups = [ "wheel" ];
              virtualisation.darwin-builder = {
                hostPort = 31023;
                workingDirectory = "/var/lib/vm/mfoc";
              };
              # Use `system_profiler SPUSBDataType` to get vendor/product IDs
              # WIP: USB passthrough does not work
              virtualisation.qemu.options = [
                "-device usb-host,vendorid=0x067b,productid=0x2303"
              ];
            }
          )
        ];
      };
    in
    pkgs.writeShellScriptBin "create-builder" ''
      ln -snf /var/lib/darwin-builder/keys /var/lib/vm/mfoc/keys
      ${pkgs.lib.getExe builder};
    '';
in

devshell.mkShell {
  packages = [
    vm-pn532
  ];
}
