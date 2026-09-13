{
  lib,
  stdenv,
  curl,
  deepseek-harness,
  runCommand,
  writableTmpDirAsHomeHook,
}:

# Boots the web profile and checks it serves a page. Catches the two
# fragile pieces: the loader's bare import() of workspace packages, and
# the --expose-internals flag.
runCommand "deepseek-harness-web-boot"
  {
    nativeBuildInputs = [
      curl
      writableTmpDirAsHomeHook
    ];
    # chokidar's native fs.watch fails with "EMFILE: too many open files"
    # in the darwin sandbox, use stat polling there.
    env.CHOKIDAR_USEPOLLING = lib.optionalString stdenv.hostPlatform.isDarwin "true";
    __darwinAllowLocalNetworking = true;
  }
  ''
    cd "$HOME"
    ${lib.getExe deepseek-harness} --profile web --no-open --port 0 >server.log 2>&1 &
    pid=$!
    trap 'kill $pid 2>/dev/null || true' EXIT

    # The web profile requires the ?token= from the launch URL (401
    # without it). -c turns on cookie handling for the token redirect.
    # --port 0 avoids clashing with anything already on 3080.
    for i in {1..60}; do
      url=$(sed -n 's#.*dsh web: \(http://[^[:space:]]*\).*#\1#p' server.log | head -1)
      if [ -n "$url" ]; then
        if curl --noproxy '*' -fsSL -c cookies.txt "$url" >page.html \
          && grep -q '<!doctype html>' page.html; then
          touch $out
          exit 0
        fi
      fi
      sleep 1
    done

    echo "dsh web profile failed to serve ''${url:-its web UI}"
    cat server.log
    exit 1
  ''
