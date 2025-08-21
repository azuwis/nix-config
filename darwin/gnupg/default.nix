{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.etc."gnupg/gpg-agent.conf".text = ''
    default-cache-ttl 14400
    max-cache-ttl 14400
  '';
  # Open Keychain Access, search for "GnuPG" and delete the entry
  system.defaults.CustomUserPreferences = {
    "org.gpgtools.pinentry-mac" = {
      "UseKeychain" = false;
    };
  };
}
