{ config, lib, pkgs, ... }:

{
  system.activationScripts.hostname.text = ''
    echo >&2 "setting up hostname in /etc/hosts..."
    if grep -q nix-darwin /etc/hosts
    then
        sed -i -e "s/^127.0.0.1 .* # nix-darwin$/127.0.0.1 ${config.networking.hostName} # nix-darwin/" /etc/hosts
    else
        echo "127.0.0.1 ${config.networking.hostName} # nix-darwin" >> /etc/hosts
    fi
  '';
}
