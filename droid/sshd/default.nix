{
  config,
  lib,
  pkgs,
  ...
}:

let
  port = 8022;
in

{
  build.activation.sshd = ''
    if [ ! -e /etc/ssh/ssh_host_rsa_key ]; then
      $VERBOSE_ECHO "Generating host keys..."
      $DRY_RUN_CMD ${pkgs.openssh}/bin/ssh-keygen -t rsa -b 4096 -f "/etc/ssh/ssh_host_rsa_key" -N ""
    fi
  '';

  environment.etc."ssh/sshd_config".text = ''
    AcceptEnv LANG LC_*
    KbdInteractiveAuthentication no
    PasswordAuthentication no
    PermitRootLogin no
    Port ${toString port}
    PrintMotd no
  '';

  environment.packages = [
    (pkgs.writeShellScriptBin "sshd-start" ''
      echo "Starting sshd on port ${toString port}"
      ${pkgs.openssh}/bin/sshd
    '')
  ];
}
