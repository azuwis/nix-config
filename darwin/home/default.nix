{
  config,
  lib,
  pkgs,
  ...
}:

{
  system.activationScripts.postActivation.text = ''
    makeHomeEntry() {
      source="$1"
      target="${config.system.primaryUserHome}/$2"
      if [ ! -e "$target" ] || { [ -L "$target" ] && [ "$(readlink -f "$target")" != "$source" ]; }; then
        ln -sf "$source" "$target"
      fi
    }
    ${lib.concatMapStringsSep "\n" (
      homeEntry:
      lib.escapeShellArgs [
        "makeHomeEntry"
        # Force local source paths to be added to the store
        "${homeEntry.source}"
        homeEntry.target
      ]
    ) (lib.attrValues config.home.file)}
    unset -f makeHomeEntry
  '';
}
