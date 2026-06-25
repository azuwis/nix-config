{
  lib,
  writeShellApplication,
  bubblewrap,
  closureInfo,
  glibcLocales,
  makeWrapper,
  path,
  runCommandLocal,
  bash,
  cacert,
  coreutils,
  curl,
  diffutils,
  fd,
  file,
  findutils,
  gawk,
  gh,
  git,
  gnugrep,
  gnused,
  jq,
  less,
  nix,
  python3,
  ripgrep,
  tinyxxd,
  unzip,
  which,
}:

{
  name,
  agentPackage,
  agentWrapperArgs ? [ ],
  allowWrite ? [ ],
  penPackages ? [
    bash
    cacert
    coreutils
    curl
    diffutils
    fd
    file
    findutils
    gawk
    gh
    git
    gnugrep
    gnused
    jq
    less
    nix
    python3
    ripgrep
    tinyxxd
    unzip
    which
  ],
  extraPenPackages ? [ ],
  extraClosurePackages ? [ ],
  extraBwrapArgs ? [ ],
  extraPassthru ? { },
}:

let
  wrappedAgentPackage =
    if agentWrapperArgs == [ ] then
      agentPackage
    else
      runCommandLocal agentPackage.name
        {
          inherit (agentPackage) meta;
          nativeBuildInputs = [ makeWrapper ];
        }
        ''
          exe="${lib.getExe agentPackage}"
          makeWrapper "$exe" "$out/bin/$(basename "$exe")" \
            ${lib.escapeShellArgs agentWrapperArgs}
        '';

  nixpkgs =
    let
      str = toString path;
    in
    builtins.appendContext str {
      "${str}" = {
        path = true;
      };
    };

  penClosure = closureInfo {
    rootPaths =
      penPackages
      ++ extraPenPackages
      ++ extraClosurePackages
      ++ [
        glibcLocales
        nixpkgs
        wrappedAgentPackage
      ];
  };

  penNixConf = runCommandLocal "pen-nix-conf" { } ''
    mkdir -p "$out"
    cat >"$out/nix.conf" <<EOF
    experimental-features = nix-command flakes
    flake-registry = $out/registry.json
    EOF
    cat >"$out/registry.json" <<EOF
    {
      "flakes": [
        {
          "from": { "id": "nixpkgs", "type": "indirect" },
          "to": { "path": "${nixpkgs}", "type": "path" }
        }
      ],
      "version": 2
    }
    EOF
  '';

  penPath = lib.makeBinPath (penPackages ++ extraPenPackages ++ [ wrappedAgentPackage ]);

  # Shared bash preamble used by both the main wrapper and passthru.shell
  penPreamble = ''
    sanitized_cwd="''${PWD//\//_}"
    rootdir="$HOME/.cache/pen/$sanitized_cwd"

    mkdir -p "$rootdir$HOME" "$rootdir/tmp"

    # Import closure into nix db on first run
    if [ ! -e "$rootdir/nix/var/nix/db/db.sqlite" ]; then
      NIX_STATE_DIR="$rootdir/nix/var/nix" nix-store --load-db < "${penClosure}/registration"
    fi

    bwrap_args+=(
      --die-with-parent
      --unshare-all
      --share-net
      --hostname pen
      --clearenv
      --setenv HOME "$HOME"
      --setenv LANG "en_US.UTF-8"
      --setenv LOCALE_ARCHIVE "${glibcLocales}/lib/locale/locale-archive"
      --setenv NIX_PATH "nixpkgs=flake:nixpkgs"
      --setenv PATH "${penPath}"
      --setenv SHELL /bin/sh
      --setenv SSL_CERT_FILE "${cacert}/etc/ssl/certs/ca-bundle.crt"
      --setenv TERM "$TERM"
      --bind "$rootdir" /
      --proc /proc
      --dev /dev
      --ro-bind "${penNixConf}" /etc/nix
      --ro-bind /etc/hosts /etc/hosts
      --ro-bind /etc/localtime /etc/localtime
      --ro-bind /etc/nsswitch.conf /etc/nsswitch.conf
      --ro-bind /etc/resolv.conf /etc/resolv.conf
      --ro-bind-try /etc/gitconfig /etc/gitconfig
      --symlink "${lib.getExe bash}" /bin/sh
      --symlink "${lib.getExe' coreutils "env"}" /usr/bin/env
    )

    while IFS= read -r storePath; do
      bwrap_args+=(--ro-bind "$storePath" "$storePath")
    done < "${penClosure}/store-paths"

    # allowWrite expansion
    # shellcheck disable=SC2088
    allow_entries=(${lib.escapeShellArgs allowWrite})
    for entry in "''${allow_entries[@]}"; do
      if [ "$entry" = "." ]; then
        bwrap_args+=(--bind "$PWD" "$PWD")
      elif [[ "$entry" == \~/* ]]; then
        expanded="''${entry/#\~/$HOME}"
        bwrap_args+=(--bind "$expanded" "$expanded")
      else
        bwrap_args+=(--bind "$entry" "$entry")
      fi
    done

    bwrap_args+=(${lib.escapeShellArgs extraBwrapArgs})
  '';

in

writeShellApplication {
  inherit name;
  derivationArgs = {
    passthru = {
      shell = writeShellApplication {
        name = "pen-shell";
        derivationArgs.preferLocalBuild = true;
        runtimeInputs = [
          bubblewrap
          coreutils
          nix
        ];
        text = penPreamble + ''
          bwrap "''${bwrap_args[@]}" -- ${lib.getExe bash} --norc "$@"
        '';
      };
    }
    // extraPassthru;
    preferLocalBuild = true;
    meta.platforms = lib.platforms.linux;
  };

  runtimeInputs = [
    bubblewrap
    coreutils
    nix
  ];

  text = penPreamble + ''
    # Separate --agent args -- --bwrap args
    agent_args=()
    bwrap_extra_args=()
    found_sep=false
    for arg in "$@"; do
      if [ "$found_sep" = false ]; then
        if [ "$arg" = "--" ]; then
          found_sep=true
        else
          agent_args+=("$arg")
        fi
      else
        bwrap_extra_args+=("$arg")
      fi
    done

    exec bwrap "''${bwrap_args[@]}" "''${bwrap_extra_args[@]}" -- \
      ${lib.getExe wrappedAgentPackage} "''${agent_args[@]}"
  '';
}
