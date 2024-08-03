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
  version = "0-unstable-2024-07-15";

  src = fetchFromGitHub {
    owner = "FelixKratz";
    repo = "SbarLua";
    rev = "19ca262c39cc45f1841155697dffd649cc119d9c";
    hash = "sha256-nz8NAeoprQ7OeFfs+7ixd6EFJyJV35WZK4mAS5izn8k=";
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
