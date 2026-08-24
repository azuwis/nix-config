{
  lib,
  formats,
  treefmt,
  nixfmt,
  pedantix,
  shfmt,
  stylua,
  yamlfmt,
}:

let
  toml = formats.toml { };
in

treefmt.withConfig {
  settings = {
    global = {
      excludes = [
        "*.lock"
        "*.patch"
        ".gitignore"
        "hosts/hardware-*.nix"
      ];
      on-unmatched = "warn";
      tree-root-file = "shell.nix";
    };

    formatter.nixfmt = {
      command = lib.getExe nixfmt;
      includes = [ "*.nix" ];
      priority = 1;
    };

    formatter.pedantix-package = {
      command = lib.getExe pedantix;
      options = [
        "--config"
        (toml.generate "pedantix-package.toml" {
          formatter-command = [ (lib.getExe nixfmt) ];
          args.first = [
            "lib"
            "stdenv"
            "stdenvNoCC"
            "buildHomeAssistantComponent"
            "rustPlatform"
            "fetchurl"
            "fetchFromCodeberg"
            "fetchFromGitHub"
            "fetchFromGitLab"
            "fetchFromGitea"
          ];
          args.last = [
            "nix-update-script"
            "<defaulted>"
            "..."
          ];
          attrs.first = [
            # buildHomeAssistantComponent
            "url"
            "owner"
            "repo"
            "tag"
            "rev"
            "hash"
            "domain"
            # name
            "name"
            "pname"
            "version"
            # Python
            "format"
            "pyproject"
            # build control
            "strictDeps"
            "__structuredAttrs"
            # source
            "src"
            "sourceRoot"
            "dontUnpack"
            "unpackCmd"
            # language-specific fetch hashes
            "cargoDeps"
            "cargoLock"
            "cargoHash"
            "vendorHash"
            "npmDepsHash"
            # outputs
            "outputs"
            # patches and fixes
            "patches"
            "postUnpack"
            "postPatch"
            # build backend
            "build-system"
            "subPackages"
            # build dependencies
            "depsBuildBuild"
            "nativeBuildInputs"
            "buildInputs"
            # runtime dependencies
            "dependencies"
            "propagatedBuildInputs"
            # hardening / wrapping
            "hardeningDisable"
            "makeWrapperArgs"
            # phases
            "phases"
            # configure
            "dontConfigure"
            "preConfigure"
            "configureFlags"
            "cmakeFlags"
            "mesonBuildType"
            "mesonFlags"
            "makeFlags"
            "npmInstallFlags"
            "buildFlags"
            "env"
            "postConfigure"
            "configurePhase"
            # build
            "dontBuild"
            "dontNpmBuild"
            "preBuild"
            "buildPhase"
            "postBuild"
            # check
            "doCheck"
            "nativeCheckInputs"
            "checkInputs"
            "preCheck"
            "checkFlags"
            "checkPhase"
            "postCheck"
            # install
            "preInstall"
            "installPhase"
            "postInstall"
            # fixup
            "preFixup"
            "postFixup"
            # installCheck
            "doInstallCheck"
            "nativeInstallCheckInputs"
            "installCheckPhase"
          ];
          attrs.last = [
            "passthru"
            "meta"
          ];
          overrides = [
            {
              path = "**.src";
              attrs.first = [
                "domain"
                "url"
                "owner"
                "repo"
                "rev"
                "tag"
                "rootDir"
                "nonConeMode"
                "sparseCheckout"
                "hash"
                "sha256"
                "fetchSubmodules"
              ];
            }
            {
              path = "**.meta";
              attrs.first = [
                "description"
                "longDescription"
                "homepage"
                "changelog"
                "license"
                "sourceProvenance"
                "maintainers"
                "mainProgram"
                "teams"
                "pkgConfigModules"
                "platforms"
              ];
              attrs.last = [
                "badPlatforms"
                "broken"
              ];
            }
          ];
        })
      ];
      includes = [ "pkgs/**.nix" ];
      excludes = [
        "pkgs/by-name/pe/pen-*"
        "pkgs/by-name/fe/fence-*"
      ];
    };

    formatter.shfmt = {
      command = lib.getExe shfmt;
      options = [ "-w" ];
      includes = [
        "*.sh"
        "*.envrc"
        ".githooks/*"
        "pkgs/by-name/sc/scripts/bin/*"
        "scripts/os"
        "scripts/update"
      ];
    };

    formatter.stylua = {
      command = lib.getExe stylua;
      includes = [ "*.lua" ];
    };

    formatter.yamlfmt = {
      command = lib.getExe yamlfmt;
      includes = [
        "*.yaml"
        "*.yml"
      ];
    };
  };
}
