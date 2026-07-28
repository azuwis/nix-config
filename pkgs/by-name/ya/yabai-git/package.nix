{ yabai, nix-update-script }:

yabai.overrideAttrs (old: {
  pname = "yabai-git";
  version = "unstable-2023-05-16";

  src = old.src.override {
    rev = "4d81baf14f7219ed2d929761fed1186bcd793b29";
    sha256 = "03qmwk0qb9wzh6nlk06zb3r1ff6abw3xawdhxbmis98678zwkzh7";
  };

  passthru = (old.passthru or { }) // {
    enable = false;
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };
})
