{ withSystem, ... }:

{
  flake.packages.aarch64-darwin = withSystem "aarch64-darwin" (
    { pkgs, ... }:
    {
      vm-mfoc = pkgs.darwin.linux-builder.override {
        modules = [
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
            # WIP:
            # 1) USB passthrough does not work
            # 2) Multiple linux-builder override /etc/nix/builder_ed25519.pub file
            virtualisation.qemu.options = [
              "-device usb-host,vendorid=0x067b,productid=0x2303"
            ];
          }
        ];
      };
    }
  );
}
