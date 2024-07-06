{
  lib,
  moonlight-qt,
  nix-update-script,
}:

moonlight-qt.overrideAttrs (old: {
  pname = "moonlight-git";
  version = "6.0.1-unstable-2024-07-06";

  src = old.src.override {
    rev = "d085722911ef100e8de5debfdf53fca4675d606e";
    sha256 = "sha256-LuROMq/eIxs+PaeGutPcSa6qftV3vanAG1+4MGm5ivc=";
  };

  patches = [ ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
})
