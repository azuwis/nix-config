{
  lib,
  fetchFromGitHub,
  lua55Packages,
  pkg-config,
  nix-update-script,
}:

lua55Packages.buildLuaPackage {
  pname = "rift-lua";
  version = "0-unstable-2026-09-07";

  src = fetchFromGitHub {
    owner = "acsandmann";
    repo = "rift.lua";
    rev = "c5c087daf5da63e9b29e6c448ccabe364b7e13af";
    hash = "sha256-QFO3ed2zlmwSVfdvXxnxn80CNWiclOXW6V8OzgmogF4=";
  };

  nativeBuildInputs = [ pkg-config ];

  installFlags = [ "INSTALL_DIR=$(LUA_LIBDIR)" ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Lua client for rift-wm";
    homepage = "https://github.com/acsandmann/rift.lua";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ azuwis ];
    platforms = lib.platforms.darwin;
  };
}
