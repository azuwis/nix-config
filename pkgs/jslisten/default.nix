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
    rev = "51fb2f5fb3f7420e01a1b0c6b593e9824233e3f4";
    hash = "sha256-6KAXzO/1Sm0fyeN9hO1OKrMNOZNKzwD/+amrbGMlRFo=";
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
