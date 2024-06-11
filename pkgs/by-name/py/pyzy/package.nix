{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  pkg-config,
  python3,
  glib,
  libuuid,
  sqlite,
}:

stdenv.mkDerivation {
  pname = "pyzy";
  version = "0-unstable-2023-02-28";

  src = fetchFromGitHub {
    owner = "openSUSE";
    repo = "pyzy";
    rev = "ec719d053bd491ec64fe68fe0d1699ca6039ad80";
    hash = "sha256-wU7EgP/CPNhBx9N7mOu0WdnoLazzpQtbRxmBKrTUbKM=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    python3
  ];

  buildInputs = [
    glib
    libuuid
    sqlite
  ];

  postPatch = ''
    patchShebangs ./data/db/android/create_db.py
  '';

  meta = with lib; {
    description = "The Chinese PinYin and Bopomofo conversion library";
    homepage = "https://github.com/openSUSE/pyzy";
    license = licenses.lgpl21;
    maintainers = with maintainers; [ azuwis ];
    platforms = platforms.linux;
  };
}
