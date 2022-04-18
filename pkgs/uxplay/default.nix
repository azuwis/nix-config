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
  version = "1.49";

  src = fetchFromGitHub {
    owner = "FDH2";
    repo = "UxPlay";
    rev = "v${version}";
    sha256 = "sha256-k4ZZ0BxqSndxnbe9Tlob43800sWmwcubiajlT1kJv7M=";
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
    # gst_all_1.gst-vaapi
  ];

  meta = with lib; {
    homepage = "https://github.com/FDH2/UxPlay";
    description = "AirPlay Unix mirroring server";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ azuwis ];
    platforms = platforms.unix;
  };
}