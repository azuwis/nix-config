{
  lib,
  moonlight-qt,
  nix-update-script,
}:

moonlight-qt.overrideAttrs (old: {
  pname = "moonlight-git";
  version = "6.0.1-unstable-2024-07-13";

  src = old.src.override {
    rev = "3580286807a09d9737d9a95160d3d96f3a6aa5d6";
    sha256 = "sha256-+6YKxVRjna8/4jyatr1NtGiFIFhXE3urxAmXxmCtuRo=";
  };

  patches = [ ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  # Workaround for nix-update 1.4.0, https://github.com/Mic92/nix-update/pull/247
  meta.position = null;
})
