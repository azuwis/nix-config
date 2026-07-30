{
  fzf,
  grub2,
  writeShellApplication,
}:

writeShellApplication {
  name = "grub-reboot-menu";
  runtimeInputs = [
    fzf
    grub2
  ];
  text = builtins.readFile ./grub-reboot-menu.sh;
}
