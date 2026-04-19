{
  lib,
  stdenv,
  makeWrapper,
  runCommand,
  writeShellApplication,
  bash,
  cacert,
  claude-code,
  coreutils,
  fd,
  findutils,
  git,
  gnugrep,
  gnused,
  jq,
  ripgrep,
  which,
  bubblewrap,
  fence,
  glibcLocales,
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

        exportReferencesGraph.closure = fencePackages ++ [ fenceShell ];

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
          filesystem = rec {
            StrictDenyRead = true;
            allowGitConfig = true;
            # Also add to allowRead on Darwin for listing dir contents
            allowRead = lib.optionals stdenv.hostPlatform.isDarwin (
              allowWrite
              ++ [
                "/etc/localtime"
                "/usr/share/locale"
              ]
            );
            allowWrite = [
              "."
              "~/.claude"
              "~/.claude.json"
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
      (
        ''
          makeWrapper "${lib.getExe bash}" "$out/bin/bash" \
        ''
        + lib.optionalString stdenv.hostPlatform.isDarwin ''
          --run 'export CLAUDE_CODE_TMPDIR="$HOME/.claude/tmp"' \
        ''
        + lib.optionalString stdenv.hostPlatform.isLinux ''
          --set LOCALE_ARCHIVE "${glibcLocales}/lib/locale/locale-archive" \
        ''
        + ''
          --set CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC "1" \
          --set LANG "en_US.UTF-8" \
          --set NIX_SSL_CERT_FILE "${cacert}/etc/ssl/certs/ca-bundle.crt" \
          --set PATH "${lib.makeBinPath fencePackages}" \
          --set SHELL "${lib.getExe bash}"
        ''
        + lib.optionalString stdenv.hostPlatform.isLinux ''
          makeWrapper "${lib.getExe bubblewrap}" "$out/bin/bwrap" \
            --add-flags '--unshare-all --hostname fence' \
            --add-flags '--clearenv --setenv HOME "$HOME" --setenv TERM "$TERM"' \
            --add-flags '--ro-bind /etc/localtime /etc/localtime'
        ''
      );
in

# fence-claude <claude_args> -- <fence_args>
writeShellApplication {
  name = "fence-claude";
  derivationArgs.passthru.shell = writeShellApplication {
    name = "fence-shell";
    derivationArgs.preferLocalBuild = true;
    runtimeInputs = [ fenceShell ];
    text = ''
      exec ${lib.getExe fence} --settings ${fenceSettings} "$@" -- ${lib.getExe bash} --norc
    '';
  };
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
    # Ensure ~/.claude.json exists to prevent fence/bubblewrap from hanging
    # on a bind-mount of a nonexistent file.
    # hasCompletedOnboarding skips the onboarding flow, which would fail
    # with ERR_BAD_REQUEST inside the sandbox due to no network access.
    if [ ! -f ~/.claude.json ]; then
      echo '{"hasCompletedOnboarding": true}' > ~/.claude.json
    fi
    mkdir -p ~/.claude

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
