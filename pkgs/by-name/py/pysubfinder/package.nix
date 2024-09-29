{
  lib,
  fetchFromGitHub,
  python3,
  nix-update-script,
}:

python3.pkgs.buildPythonApplication {
  pname = "subfinder";
  version = "2.2.2-pre-unstable-2024-02-14";

  src = fetchFromGitHub {
    owner = "ausaki";
    repo = "subfinder";
    rev = "fe15165d143f4666731fa5246c2e716af6411c36";
    sha256 = "sha256-SeensfAKYU3HUjGaF3hzrnXZkQYs/15IH3msNEl0iS8=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    requests
    lxml
    beautifulsoup4
    gevent
    rarfile
    setuptools
    six
  ];

  doCheck = false;

  postPatch = ''
    substituteInPlace setup.py --replace-fail "bs4" "beautifulsoup4"
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = with lib; {
    description = "Subtitle finder";
    homepage = "https://github.com/ausaki/subfinder";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ azuwis ];
  };
}
