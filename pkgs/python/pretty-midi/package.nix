{
  lib,
  buildPythonPackage,
  fetchPypi,
  importlib-resources,
  mido,
  numpy,
  pytestCheckHook,
  setuptools,
  six,
  nix-update-script,
}:

buildPythonPackage rec {
  pname = "pretty-midi";
  version = "0.2.11.post0";

  pyproject = true;

  src = fetchPypi {
    inherit version;
    hash = "sha256-yR5AybCHsFEfUDw++7qJK0HnBIyDHK/cy/a6llYyoL8=";
    pname = "pretty_midi";
  };

  build-system = [ setuptools ];

  dependencies = [
    importlib-resources
    mido
    numpy
    six
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  pythonImportsCheck = [ "pretty_midi" ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Functions and classes for handling MIDI data conveniently";
    homepage = "https://github.com/craffel/pretty-midi";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ azuwis ];
  };
}
