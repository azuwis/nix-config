{ lib
, stdenv
, fetchFromGitHub
, udev
}:

stdenv.mkDerivation {
  pname = "jslisten";
  version = "unstable-2021-02-07";

  src = fetchFromGitHub {
    owner = "workinghard";
    repo = "jslisten";
    rev = "3c84610b7422e06451d454f5eedde4e9e59b78dd";
    hash = "sha256-ZKxA+Hbk8kkqMzO1wTZtcIhNwaHYylD+qIPgf/MydAk=";
  };

  buildInputs = [
    udev
  ];

  installPhase = ''
    runHook preInstall

    install -D bin/jslisten $out/bin/jslisten

    runHook postInstall
  '';

  meta = with lib; {
    description = "Listen to gamepad inputs and trigger a command";
    homepage = "https://github.com/workinghard/jslisten";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ azuwis ];
    platforms = platforms.linux;
  };
}
