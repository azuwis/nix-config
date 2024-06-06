{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.packages = with pkgs; [
    inetutils
    procps
  ];
}
