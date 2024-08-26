{
  lib,
  buildLuaPackage,
  fetchFromGitHub,
  darwin,
  lua,
  nix-update-script,
}:

let
  inherit (darwin.apple_sdk.frameworks) CoreFoundation;
in

buildLuaPackage {
  pname = "sbarlua";
  version = "0-unstable-2024-08-12";

  src = fetchFromGitHub {
    owner = "FelixKratz";
    repo = "SbarLua";
    rev = "437bd2031da38ccda75827cb7548e7baa4aa9978";
    hash = "sha256-F0UfNxHM389GhiPQ6/GFbeKQq5EvpiqQdvyf7ygzkPg=";
  };

  postPatch = ''
    substituteInPlace makefile --replace-fail " bin/liblua.a" ""
  '';

  buildInputs = [ CoreFoundation ];

  preBuild = ''
    makeFlagsArray+=(
      INSTALL_DIR="$out/lib/lua/${lua.luaversion}"
      LIBS="-llua -framework CoreFoundation"
    )
    mkdir bin
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Lua API for SketchyBar";
    homepage = "https://github.com/FelixKratz/SbarLua";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ azuwis ];
    platforms = lib.platforms.darwin;
  };
}
