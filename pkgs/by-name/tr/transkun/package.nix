{
  lib,
  fetchPypi,
  python3Packages,
  nix-update-script,
}:

python3Packages.buildPythonApplication rec {
  pname = "transkun";
  version = "2.0.1";

  format = "wheel";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-fX9b+IsNIffaBBWwic/zvLy92gTho8lxmWSUeULIWf4=";
    dist = "py3";
    format = "wheel";
    python = "py3";
  };

  # Dependencies for the CLI. Training, plotting and evaluation deps are not
  # included. transkunEval is broken upstream and unsupported.
  dependencies = with python3Packages; [
    moduleconf
    numpy
    pretty-midi
    pydub
    soxr
    torch
    torchaudio
  ];

  # setuptools 83 no longer ships pkg_resources, so find the bundled
  # checkpoint with importlib.resources instead.
  # ModelTransformer imports Evaluation (and thus mir-eval) only for training
  # statistics. Drop it and the broken transkunEval entry point.
  postInstall = ''
    substituteInPlace $out/${python3Packages.python.sitePackages}/transkun/transcribe.py \
      --replace-fail 'import pkg_resources' 'from importlib.resources import files' \
      --replace-fail 'pkg_resources.resource_filename(__name__, "pretrained/2.0.pt")' 'str(files("transkun").joinpath("pretrained", "2.0.pt"))' \
      --replace-fail 'pkg_resources.resource_filename(__name__, "pretrained/2.0.conf")' 'str(files("transkun").joinpath("pretrained", "2.0.conf"))'
    substituteInPlace $out/${python3Packages.python.sitePackages}/transkun/ModelTransformer.py \
      --replace-fail 'from .Evaluation import *' ""
    rm -f $out/bin/transkunEval
  '';

  pythonImportsCheck = [
    "transkun"
    "transkun.Data"
    "transkun.transcribe"
  ];

  # Drop training, plotting and evaluation deps from the wheel metadata.
  pythonRemoveDeps = [
    "matplotlib"
    "mir-eval"
    "ncls"
    "scipy"
    "seaborn"
    "sox"
    "tensorboard"
    "torch-optimizer"
    "tqdm"
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--url=mirror://pypi/t/transkun/" ];
  };

  meta = {
    description = "Automatic piano transcription with neural semi-CRFs";
    homepage = "https://github.com/Yujia-Yan/Transkun";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ azuwis ];
    mainProgram = "transkun";
  };
}
