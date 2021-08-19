[( self: super: {
  rime-csp = super.callPackage ./pkgs/rime-csp {};
  simple-bar = super.callPackage ./pkgs/simple-bar {};
  yabai = super.yabai.overrideAttrs (o: rec {
    version = "3.3.10-1";
    src = builtins.fetchTarball {
      url = "https://github.com/azuwis/yabai/releases/download/v3.3.10/yabai-v${version}.tar.gz";
      sha256 = "1za1b3hdns9hhhwpq3fvya2528rc17cyz9sl0jq4q6y1i35jkrm6";
    };

    installPhase = ''
      mkdir -p $out/bin
      mkdir -p $out/share/man/man1/
      cp ./archive/bin/yabai $out/bin/yabai
      cp ./archive/doc/yabai.1 $out/share/man/man1/yabai.1
    '';
  });
})]
