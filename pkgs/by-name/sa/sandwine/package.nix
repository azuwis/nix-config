{
  lib,
  fetchFromGitHub,
  python3,
  bubblewrap,
  wine64,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "sandwine";
  version = "2.0.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "hartwork";
    repo = pname;
    rev = version;
    sha256 = "sha256-cP8Hl5Suohn2nnOj8HBOTzx7GIZCOA6kMCLgdcs7dgU=";
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

  meta = with lib; {
    description = "Command-line tool to run Windows apps with Wine and bwrap/bubblewrap isolation";
    homepage = "https://github.com/hartwork/sandwine";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ azuwis ];
    platforms = platforms.linux;
  };
}
