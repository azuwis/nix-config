{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Open Keychain Access, search for "GnuPG" and delete the entry
  system.defaults.CustomUserPreferences = {
    "org.gpgtools.pinentry-mac" = {
      "UseKeychain" = false;
    };
  };
}
