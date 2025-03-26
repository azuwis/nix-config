let
  inputs = import ../inputs;
in

import (inputs.nixpkgs.outPath + "/lib")
