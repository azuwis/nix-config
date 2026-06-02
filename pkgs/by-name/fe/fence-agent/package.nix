{
  lib,
  stdenv,
  makeWrapper,
  runCommand,
  writeShellApplication,
  bash,
  cacert,
  coreutils,
  curl,
  diffutils,
  fd,
  file,
  findutils,
  gawk,
  git,
  gnugrep,
  gnused,
  jq,
  less,
  python3,
  ripgrep,
  tinyxxd,
  unzip,
  which,
  bubblewrap,
  fence,
  glibcLocales,
}:

{
  name, # wrapper name, e.g. "fence-claude"
  agentPackage, # the agent binary package, e.g. claude-code
  agentWrapperArgs ? [ ], # makeWrapper args for agentPackage
  allowWrite, # filesystem paths writable inside sandbox, e.g. ["." "~/.claude"]
  preExecScript ? "", # shell code to run before exec (mkdir, config init, etc.)
  fencePackages ? [
    bash
    cacert
    coreutils
    curl
    diffutils
    fd
    file
    findutils
    gawk
    git
    gnugrep
    gnused
    jq
    less
    python3
    ripgrep
    tinyxxd
    unzip
    which
  ], # packages available inside the sandbox
  extraFencePackages ? [ ], # additional packages to add to fencePackages
  extraClosurePackages ? [ ], # additional packages to add to the closure, but not PATH
  extraBashWrapperArgs ? [ ], # extra makeWrapper args for fenceShell bash
}:

let
  wrappedAgentPackage =
    if agentWrapperArgs == [ ] then
      agentPackage
    else
      runCommand agentPackage.name
        {
          inherit (agentPackage) meta;
          nativeBuildInputs = [
            makeWrapper
          ];
          preferLocalBuild = true;
        }
        ''
          exe="${lib.getExe agentPackage}"
          makeWrapper "$exe" "$out/bin/$(basename "$exe")" \
            ${lib.escapeShellArgs agentWrapperArgs}
        '';

  allFencePackages = fencePackages ++ extraFencePackages ++ [ wrappedAgentPackage ];

  fenceSettings =
    runCommand "fence.json"
      {
        __structuredAttrs = true;
        nativeBuildInputs = [ jq ];
        preferLocalBuild = true;

        exportReferencesGraph.closure = allFencePackages ++ extraClosurePackages ++ [ fenceShell ];

        # https://github.com/Use-Tusk/fence/blob/main/docs/configuration.md
        # https://github.com/Use-Tusk/fence/tree/main/internal/templates
        # Additional config can be set in ~/.config/fence/fence.json
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
            # /etc/localtime is a symlink, fence resolves it and binds the
            # target instead of creating the symlink path in the sandbox.
            # Handle it on Linux in the bwrap wrapper below instead.
            # On Darwin: also add to allowRead for dir listing of allowWrite paths
            allowRead = lib.optionals stdenv.hostPlatform.isDarwin (
              allowWrite
              ++ [
                "/bin/sh"
                "/etc/localtime"
                "/usr/bin/env"
                "/usr/share/locale"
              ]
            );
            inherit allowWrite;
          };
          # Default have no network access, configure in ~/.config/fence/fence.json
        };
      }
      ''
        jq '
          (.closure | map(.path) | sort) as $paths |
          .settings | .filesystem.allowRead += $paths
        ' "$NIX_ATTRS_JSON_FILE" > "$out"
      '';

  bashWrapperArgs =
    lib.optionals stdenv.hostPlatform.isLinux [
      "--set"
      "LOCALE_ARCHIVE"
      "${glibcLocales}/lib/locale/locale-archive"
    ]
    ++ extraBashWrapperArgs
    ++ [
      "--set"
      "LANG"
      "en_US.UTF-8"
      "--set"
      "NIX_SSL_CERT_FILE"
      "${cacert}/etc/ssl/certs/ca-bundle.crt"
      "--set"
      "PATH"
      "${lib.makeBinPath allFencePackages}"
      "--set"
      "SHELL"
      "${lib.getExe bash}"
    ];

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
            ${lib.escapeShellArgs bashWrapperArgs}
        ''
        + lib.optionalString stdenv.hostPlatform.isLinux ''
          makeWrapper "${lib.getExe bubblewrap}" "$out/bin/bwrap" \
            --add-flags '--unshare-all --hostname fence' \
            --add-flags '--clearenv --setenv HOME "$HOME" --setenv TERM "$TERM"' \
            --add-flags '--ro-bind /etc/localtime /etc/localtime' \
            --add-flags '--ro-bind-try /etc/gitconfig /etc/gitconfig' \
            --add-flags '--symlink ${lib.getExe bash} /bin/sh' \
            --add-flags '--symlink ${lib.getExe' coreutils "env"} /usr/bin/env'
        ''
      );

in

# ${name} <agent_args> -- <fence_args>
writeShellApplication {
  inherit name;
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
  # bwrap will refuse to run if not setuid, error: `bwrap: Unexpected
  # capabilities but not setuid`, so do not override PATH in this
  # ShellApplication, so the setuid bwrap in system PATH is used, like
  # /run/wrappers/bin/bwrap in NixOS if exist
  text = ''
    agent_args=()
    fence_args=()
    found_sep=false
    for arg in "$@"; do
      if [ "$found_sep" = false ]; then
        if [ "$arg" = "--" ]; then
          found_sep=true
        else
          agent_args+=("$arg")
        fi
      else
        fence_args+=("$arg")
      fi
    done

    ${preExecScript}
    exec ${lib.getExe fence} --settings ${fenceSettings} "''${fence_args[@]}" -- \
      ${lib.getExe wrappedAgentPackage} "''${agent_args[@]}"
  '';
}
