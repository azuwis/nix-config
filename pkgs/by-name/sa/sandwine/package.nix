{
  lib,
  fetchFromGitHub,
  python3,
  bubblewrap,
  wine64,
  nix-update-script,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "sandwine";
  version = "4.0.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "hartwork";
    repo = pname;
    rev = version;
    hash = "sha256-pH0Zi4yzOvHQI3Q58o6eOLEBbXheFkRu/AzP8felz5I=";
  };

  nativeBuildInputs = [ python3.pkgs.setuptools ];

  propagatedBuildInputs = with python3.pkgs; [ coloredlogs ];

  makeWrapperArgs = [
    ''--prefix PATH : "${
      lib.makeBinPath [
        bubblewrap
        wine64
      ]
    }"''
  ];

  passthru.skipUpdate = true;
  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Command-line tool to run Windows apps with Wine and bwrap/bubblewrap isolation";
    homepage = "https://github.com/hartwork/sandwine";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ azuwis ];
    platforms = platforms.linux;
  };
}
