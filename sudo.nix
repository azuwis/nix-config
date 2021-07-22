{ config, pkgs, ... }:

{
  environment.etc."sudoers.d/custom".text = ''
    Defaults timestamp_timeout=300
  '';
  system.patches = [
    (pkgs.writeText "pam-sudo.patch" ''
      --- a/etc/pam.d/sudo
      +++ b/etc/pam.d/sudo
      @@ -1,4 +1,5 @@
       # sudo: auth account password session
      +auth       sufficient     pam_tid.so
       auth       sufficient     pam_smartcard.so
       auth       required       pam_opendirectory.so
       account    required       pam_permit.so
    '')
  ];
}
