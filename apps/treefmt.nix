{
  lib,
  treefmt,
  nixfmt,
  shfmt,
  stylua,
  yamlfmt,
}:

treefmt.withConfig {
  settings = {
    global = {
      excludes = [
        "*.lock"
        "*.patch"
        ".gitignore"
        "hosts/hardware-*.nix"
      ];
      on-unmatched = "warn";
      tree-root-file = "shell.nix";
    };

    formatter.nixfmt = {
      command = lib.getExe nixfmt;
      includes = [ "*.nix" ];
    };

    formatter.shfmt = {
      command = lib.getExe shfmt;
      options = [ "-w" ];
      includes = [
        "*.sh"
        "*.envrc"
        ".githooks/*"
        "pkgs/by-name/sc/scripts/bin/*"
        "scripts/os"
        "scripts/update"
      ];
    };

    formatter.stylua = {
      command = lib.getExe stylua;
      includes = [ "*.lua" ];
    };

    formatter.yamlfmt = {
      command = lib.getExe yamlfmt;
      includes = [
        "*.yaml"
        "*.yml"
      ];
    };
  };
}
