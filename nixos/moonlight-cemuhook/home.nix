{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.moonlight-cemuhook;

  moonlight-cemuhook = pkgs.moonlight-qt.overrideAttrs (o: rec {
    pname = "moonlight-cemuhook";
    src = pkgs.fetchFromGitHub {
      owner = "happyharryh";
      repo = "moonlight-qt";
      rev = "04b3a697730262e36f29b457b18944be6b8daa13";
      sha256 = "sha256-njvE+wQsgzzjHib5mqiNjs9oOEwKNIoXnqmghNFG9RU=";
      fetchSubmodules = true;
    };
    patches = [ ./moonlight-cemuhook.diff ];
  });
in
{
  options.my.moonlight-cemuhook = {
    enable = mkEnableOption (mdDoc "moonlight-cemuhook");
  };

  config = mkIf cfg.enable {
    home.packages = [ moonlight-cemuhook ];
  };
}
