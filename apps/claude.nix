{
  lib,
  makeWrapper,
  runCommand,
  bash,
  cacert,
  claude-code,
  coreutils,
  fd,
  fence,
  findutils,
  git,
  gnugrep,
  gnused,
  jq,
  ripgrep,
  which,
}:

let
  packages = [
    bash
    cacert
    claude-code
    coreutils
    fd
    findutils
    git
    gnugrep
    gnused
    jq
    ripgrep
    which
  ];

  fenceSettings =
    runCommand "fence.json"
      {
        __structuredAttrs = true;
        nativeBuildInputs = [ jq ];
        preferLocalBuild = true;

        exportReferencesGraph.closure = packages;

        settings = {
          extends = "@base";
          allowPty = true;
          command = {
            acceptSharedBinaryCannotRuntimeDeny = [ "chroot" ];
          };
          devices = {
            mode = "minimal";
          };
          filesystem = {
            allowWrite = [
              "."
              "~/.claude"
              "~/.claude.json"
            ];
            denyRead = [
              "/boot"
              "/etc"
              "/mnt"
              "/root"
              "/run"
              "/srv"
              "/sys"
              "/var"
            ];
          };
        };
      }
      ''
        jq '
          (.closure | map(.path) | sort) as $paths |
          .settings | .filesystem.allowRead += $paths
        ' "$NIX_ATTRS_JSON_FILE" > "$out"
      '';
in

runCommand "claude-wrapped"
  {
    nativeBuildInputs = [
      makeWrapper
    ];
    preferLocalBuild = true;
    meta.mainProgram = "claude";
  }
  ''
    makeWrapper "${lib.getExe fence}" "$out/bin/claude" \
      --set NIX_SSL_CERT_FILE "${cacert}/etc/ssl/certs/ca-bundle.crt" \
      --set PATH "${lib.makeBinPath packages}" \
      --add-flags "--settings ${fenceSettings} ${lib.getExe claude-code}"
  ''
