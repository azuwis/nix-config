{
  pkgs ? import ../pkgs { },
  ...
}:

# Clean up:
# podman system prune --all --force
# rm -r ~/.config/containers
# rm -r ~/.local/share/containers
let
  inputs = import ../inputs;
  devshell = import inputs.devshell.outPath { nixpkgs = pkgs; };
in

devshell.mkShell {
  devshell.startup.podman.text = ''
    if [ ! -e ~/.config/containers/policy.json ]; then
      echo
      echo "---------------------------------------------------------"
      echo "Creating ~/.config/containers/policy.json"
      mkdir -p ~/.config/containers
      echo '{"default": [{"type": "insecureAcceptAnything"}]}' > ~/.config/containers/policy.json
      echo "---------------------------------------------------------"
    fi
  '';
  packages = with pkgs; [
    podman
    podman-compose
  ];
}
