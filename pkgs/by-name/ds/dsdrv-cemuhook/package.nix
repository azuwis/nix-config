{
  lib,
  fetchFromGitHub,
  bluez,
  python3,
  nix-update-script,
}:

python3.pkgs.buildPythonPackage {
  pname = "dsdrv-cemuhook";
  version = "0.5.1-unstable-2023-08-25";

  src = fetchFromGitHub {
    owner = "lirannl";
    repo = "dsdrv-cemuhook";
    rev = "ab61e413dccc6a0d23bb469e587fbda209982ff0";
    sha256 = "sha256-YSo7PwIlSqYbVhpEZam41SVLzg610G1cgoyL8S7he88=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    evdev
    pyudev
  ];

  buildInputs = [ bluez ];

  passthru.skipUpdate = true;
  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "A Sony DualShock 4 and DualSense userspace driver for Linux with basic support of cemuhook's UDP protocol";
    homepage = "https://github.com/lirannl/dsdrv-cemuhook";
    license = lib.licenses.mit;
  };
}
