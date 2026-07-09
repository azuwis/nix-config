{
  lib,
  writeShellApplication,
  bubblewrap,
  closureInfo,
  glibcLocales,
  makeWrapper,
  path,
  runCommandLocal,
  writeClosure,
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
  socat,
  tinyproxy,
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
    socat
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
        penInit
        wrappedAgentPackage
      ];
  };

  penInit = writeShellApplication {
    name = "pen-init";
    text = ''
      if [ -n "$http_proxy" ]; then
        socat TCP-LISTEN:8888,bind=127.0.0.1,fork UNIX-CONNECT:/tmp/proxy.sock 2>/dev/null &
      fi
      exec "$@"
    '';
  };

  penNixConf = runCommandLocal "pen-nix-conf" { } ''
    mkdir -p "$out"

    cat >"$out/nix.conf" <<EOF
    experimental-features = nix-command flakes
    flake-registry =
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
  #
  # ~/.config/pen/config.json example:
  #   {
  #     "bind": ["~/.android"],
  #     "ro-bind": ["~/.config/gh", ["/etc/zoneinfo/Etc/GMT-8", "/etc/localtime"]],
  #     "setenv": [["EDITOR", true], ["GITHUB_TOKEN", "ghp_xxx"]],
  #     "tmpfs": [["/tmp"]]
  #   }
  penPreamble = ''
    sanitized_cwd="''${PWD//\//_}"
    cachedir="$HOME/.cache/pen/$sanitized_cwd"
    rootdir="$cachedir/rootfs"

    mkdir -p "$rootdir$HOME" "$rootdir/tmp" "$rootdir/etc"

    if [ ! -e "$rootdir/etc/group" ]; then
      cat >"$rootdir/etc/group" <<EOF
    root:x:0:
    $(id -gn):x:$(id -g):
    EOF
    fi

    if [ ! -e "$rootdir/etc/passwd" ]; then
      cat >"$rootdir/etc/passwd" <<EOF
    root:x:0:0:root:/root:/bin/sh
    $(id -un):x:$(id -u):$(id -g):$(id -un):$HOME:/bin/sh
    EOF
    fi

    # Import closure into nix db on first run
    if [ ! -e "$rootdir/nix/var/nix/db/db.sqlite" ]; then
      NIX_STATE_DIR="$rootdir/nix/var/nix" nix-store --load-db < "${penClosure}/registration"
    fi

    bwrap_args=(
      --die-with-parent
      --unshare-all
      --hostname pen
      --clearenv
      --setenv HOME "$HOME"
      --setenv LANG "en_US.UTF-8"
      --setenv LOCALE_ARCHIVE "${glibcLocales}/lib/locale/locale-archive"
      --setenv LOGNAME "''${LOGNAME:-$(id -un)}"
      --setenv NIX_PATH "nixpkgs=flake:nixpkgs"
      --setenv PATH "${penPath}"
      --setenv SHELL /bin/sh
      --setenv SSL_CERT_FILE "${cacert}/etc/ssl/certs/ca-bundle.crt"
      --setenv TERM "$TERM"
      --setenv USER "''${USER:-$(id -un)}"
      --bind "$rootdir" /
      --proc /proc
      --dev /dev
      --ro-bind "${penNixConf}" /etc/nix
      --ro-bind /etc/hosts /etc/hosts
      --ro-bind /etc/localtime /etc/localtime
      --ro-bind-try /etc/gitconfig /etc/gitconfig
      --symlink "${lib.getExe bash}" /bin/sh
      --symlink "${lib.getExe' coreutils "env"}" /usr/bin/env
    )

    [ -n "''${COLORTERM:-}" ] && bwrap_args+=(--setenv COLORTERM "$COLORTERM")

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

    # ro-bind .git/config and .git/hooks if present, to prevent agent from tampering
    for gitfile in .git/config .git/hooks; do
      if [ -e "$gitfile" ]; then
        bwrap_args+=(--ro-bind "$PWD/$gitfile" "$PWD/$gitfile")
      fi
    done

    bwrap_args+=(${lib.escapeShellArgs extraBwrapArgs})

    if [ -e ~/.config/pen/config.json ]; then
      eval "bwrap_args+=($(jq -r '
        def expand: if startswith("~") then env.HOME + .[1:] else . end;
        to_entries[] | .key as $k | .value[] |
          if type == "string" then "--\($k)", (expand | @sh), (expand | @sh)
          elif $k == "setenv" and .[1] == true then (.[0] as $n | env[$n] // empty | @sh "--\($k) \($n) \(.)")
          else "--\($k)", (.[] | expand | @sh) end
      ' ~/.config/pen/config.json))"
    fi

    # Network isolation
    if [ -f ~/.config/pen/tinyproxy.filter ]; then
      proxydir="$cachedir/tinyproxy"
      mkdir -p "$proxydir"

      tinyproxy_bwrap_args=(
        --die-with-parent
        --unshare-all
        --share-net
        --clearenv
        --ro-bind /etc/hosts /etc/hosts
        --ro-bind /etc/localtime /etc/localtime
        --ro-bind /etc/resolv.conf /etc/resolv.conf
        --bind "$proxydir" "$proxydir"
        --ro-bind ~/.config/pen/tinyproxy.filter ~/.config/pen/tinyproxy.filter
      )
      while IFS= read -r path; do
        tinyproxy_bwrap_args+=(--ro-bind "$path" "$path")
      done < "${writeClosure [ tinyproxy ]}"

      started=
      for _ in {1..5}; do
        tinyproxy_port=$(( 61000 + RANDOM % 4536 ))

        cat >"$proxydir/tinyproxy.conf" <<EOF
    Port $tinyproxy_port
    Listen 127.0.0.1
    Filter "$HOME/.config/pen/tinyproxy.filter"
    FilterDefaultDeny Yes
    FilterType fnmatch
    FilterURLs On
    DisableViaHeader Yes
    LogFile "$proxydir/tinyproxy.log"
    LogLevel Connect
    EOF

        bwrap "''${tinyproxy_bwrap_args[@]}" -- ${lib.getExe tinyproxy} -d -c "$proxydir/tinyproxy.conf" &
        tinyproxy_pid=$!
        sleep 0.1
        if kill -0 $tinyproxy_pid 2>/dev/null; then
          started=1
          break
        fi
      done

      if [ -z "$started" ]; then
        echo "pen: tinyproxy failed to start after 5 retries, check log at $proxydir/tinyproxy.log" >&2
        exit 1
      fi

      socat UNIX-LISTEN:"$proxydir/proxy-$$.sock",unlink-early,fork TCP:127.0.0.1:"$tinyproxy_port" 2>/dev/null &
      socat_pid=$!

      trap 'kill $tinyproxy_pid $socat_pid 2>/dev/null' EXIT
      bwrap_args+=(
        --bind "$proxydir/proxy-$$.sock" /tmp/proxy.sock
        --setenv http_proxy "http://127.0.0.1:8888"
        --setenv https_proxy "http://127.0.0.1:8888"
      )
    else
      bwrap_args+=(
        --share-net
        --ro-bind /etc/resolv.conf /etc/resolv.conf
      )
    fi
  '';

  runtimeInputs = [
    bubblewrap
    coreutils
    jq
    nix
    socat
    tinyproxy
  ];
in

writeShellApplication {
  inherit name runtimeInputs;
  derivationArgs = {
    passthru = {
      shell = writeShellApplication {
        inherit runtimeInputs;
        name = "pen-shell";
        derivationArgs.preferLocalBuild = true;
        text = penPreamble + ''
          bwrap "''${bwrap_args[@]}" -- ${lib.getExe penInit} ${lib.getExe bash} --norc "$@"
        '';
      };
    }
    // extraPassthru;
    preferLocalBuild = true;
    meta.platforms = lib.platforms.linux;
  };

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

    bwrap "''${bwrap_args[@]}" "''${bwrap_extra_args[@]}" -- \
      ${lib.getExe penInit} ${lib.getExe wrappedAgentPackage} "''${agent_args[@]}"
  '';
}
