# shellcheck shell=bash disable=2154,2329

overrideConfigurePhase() {
  openwrtConfigurePhase="$configurePhase"
  unset configurePhase

  configurePhase() {
    runHook preConfigure
    @openwrtFhs@ -euo pipefail -c "eval \"$openwrtConfigurePhase\""
    runHook postConfigure
  }
}

appendToVar prePhases overrideConfigurePhase

overrideBuildPhase() {
  openwrtBuildPhase="$buildPhase"
  unset buildPhase

  buildPhase() {
    runHook preBuild
    @openwrtFhs@ -euo pipefail -c "eval \"$openwrtBuildPhase\""
    runHook postBuild
  }
}

appendToVar prePhases overrideBuildPhase
