{ lib
, stdenv
, pkg-config
, fetchFromGitHub
, cmake
, wrapGAppsHook
, avahi
, avahi-compat
, openssl
, gst_all_1
, libplist
}:

stdenv.mkDerivation rec {
  pname = "uxplay";
  version = "1.48";

  src = fetchFromGitHub {
    owner = "FDH2";
    repo = "UxPlay";
    # rev = "v${version}";
    # https://github.com/FDH2/UxPlay/issues/91
    rev = "3401427e006a5581177e7cc5cf03f903f5859246";
    sha256 = "sha256-nn2hTEXg7ieMIy33atLeelISbfaBWRZce+0aAmEYJ7Q=";
  };

  nativeBuildInputs = [
    cmake
    openssl
    libplist
    pkg-config
    wrapGAppsHook
  ];

  buildInputs = [
    avahi
    avahi-compat
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
  ];

  meta = with lib; {
    homepage = "https://github.com/FDH2/UxPlay";
    description = "AirPlay Unix mirroring server";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ azuwis ];
    platforms = platforms.unix;
  };
}
