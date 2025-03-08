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
    AuthorizedKeysFile %h/.ssh/authorized_keys /etc/ssh/authorized_keys.d/%u
    KbdInteractiveAuthentication no
    PasswordAuthentication no
    PermitRootLogin no
    Port ${toString port}
    PrintMotd no
  '';

  environment.etc."ssh/authorized_keys.d/nix-on-droid".text =
    lib.concatStringsSep "\n" config.my.keys;

  environment.packages = [
    (pkgs.writeShellScriptBin "sshd-start" ''
      echo "Starting sshd on port ${toString port}"
      ${pkgs.openssh}/bin/sshd
    '')
  ];

  hm.programs.zsh.logoutExtra = ''
    pkill sshd
  '';
}
