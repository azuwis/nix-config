{
  lib,
  makeWrapper,
  runCommand,
  writeShellApplication,
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
  fencePackages = [
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

        exportReferencesGraph.closure = fencePackages;

        # https://github.com/Use-Tusk/fence/blob/main/docs/configuration.md
        # https://github.com/Use-Tusk/fence/tree/main/internal/templates
        # Additional config can be set in ~/.config/fence/fence.json, like:
        # {
        #   "network": {
        #     "allowedDomains": [
        #       "your.api.address"
        #     ]
        #   }
        # }
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
          # Default have no network access, uncomment to use anthropic API:
          # network = {
          #   allowedDomains = [
          #     "*.anthropic.com"
          #   ];
          #   deniedDomains = [
          #     "statsig.anthropic.com"
          #     "*.sentry.io"
          #   ];
          # };
        };
      }
      ''
        jq '
          (.closure | map(.path) | sort) as $paths |
          .settings | .filesystem.allowRead += $paths
        ' "$NIX_ATTRS_JSON_FILE" > "$out"
      '';

  fenceShell =
    runCommand "fence-shell"
      {
        nativeBuildInputs = [
          makeWrapper
        ];
        preferLocalBuild = true;
      }
      ''
        makeWrapper "${lib.getExe bash}" "$out/bin/bash" \
          --set NIX_SSL_CERT_FILE "${cacert}/etc/ssl/certs/ca-bundle.crt" \
          --set PATH "${lib.makeBinPath fencePackages}"
      '';
in

# fence-claude <claude_args> -- <fence_args>
# Add `"hasCompletedOnboarding": true` to ~/.claude.json if fail to startup for first time
writeShellApplication {
  name = "fence-claude";
  derivationArgs.preferLocalBuild = true;
  # fence use bash found in PATH to run helper script inside bwrap to setup
  # proxy etc., the helper script need tools like `mkdir` `rm`, since inside
  # the bwrap, only the closure of fencePackages are accessible, provide a
  # fenceShell with correct PATH, so those tools can be found, instead of
  # trying to use tools outside of bwrap
  runtimeInputs = [ fenceShell ];
  # When using something like this the give CAP_BPF to fence:
  # security.wrappers.claude = {
  #   source = "${lib.getExe pkgs.fence-claude}";
  #   owner = "root";
  #   group = "wheel";
  #   permissions = "u+rx,g+x";
  #   capabilities = "cap_bpf+ep";
  # };
  # bwrap will refuse to run if not setuid, error: `bwrap: Unexpected
  # capabilities but not setuid`, so do not override PATH in this
  # ShellApplication, so the setuid bwrap in system PATH is used, like
  # /run/wrappers/bin/bwrap in NixOS if exist
  text = ''
    claude_args=()
    fence_args=()
    found_sep=false
    for arg in "$@"; do
      if [ "$found_sep" = false ]; then
        if [ "$arg" = "--" ]; then
          found_sep=true
        else
          claude_args+=("$arg")
        fi
      else
        fence_args+=("$arg")
      fi
    done

    exec ${lib.getExe fence} --settings ${fenceSettings} "''${fence_args[@]}" -- \
      ${lib.getExe claude-code} --allow-dangerously-skip-permissions "''${claude_args[@]}"
  '';
}
