{
  lib,
  buildPythonPackage,
  fetchPypi,
  nix-update-script,
}:

buildPythonPackage rec {
  pname = "moduleconf";
  version = "0.1.4";

  format = "wheel";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-R/1I9c1WbjqxmBBqZt++Y+S56ukk+NtY1m33q6JeXDk=";
    dist = "py3";
    format = "wheel";
    python = "py3";
  };

  pythonImportsCheck = [ "moduleconf" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--url=mirror://pypi/m/moduleconf/" ];
  };

  meta = {
    description = "Minimal module-specific configuration tool for fast experimenting";
    homepage = "https://github.com/Yujia-Yan/moduleconf";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ azuwis ];
  };
}
