{ lib
, fetchFromGitHub
, bluez
, python3
}:

python3.pkgs.buildPythonPackage {
  pname = "dsdrv-cemuhook";
  version = "unstable-2021-08-04";

  src = fetchFromGitHub {
    owner = "lirannl";
    repo = "dsdrv-cemuhook";
    rev = "0a04ecdfa908b29548665ce2dac06c8a6f572378";
    sha256 = "0bhh5q6hl1ba7w5b5rm5a4gh7n169v3k6lz7szvzmbs79gpxmb2m";
  };

  propagatedBuildInputs = with python3.pkgs; [
    evdev
    pyudev
  ];

  buildInputs = [ bluez ];

  meta = {
    description = "A Sony DualShock 4 and DualSense userspace driver for Linux with basic support of cemuhook's UDP protocol";
    homepage = "https://github.com/lirannl/dsdrv-cemuhook";
    license = lib.licenses.mit;
  };
}
