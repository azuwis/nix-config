# shellcheck shell=bash disable=SC2154,SC2329

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
