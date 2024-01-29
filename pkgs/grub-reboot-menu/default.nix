{ writeShellApplication
, fzf
, grub2
}:

writeShellApplication {
  name = "grub-reboot-menu";
  text = builtins.readFile ./grub-reboot-menu.sh;
  runtimeInputs = [
    fzf
    grub2
  ];
}
