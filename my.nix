{ config, lib, pkgs, ... }:

{
  options.my = {
    user = lib.mkOption { type = lib.types.str; };
    name = lib.mkOption { type = lib.types.str; };
    email = lib.mkOption { type = lib.types.str; };
  };
  config = {
    my = {
      user = "azuwis";
      name = "Zhong Jianxin";
      email = "azuwis@gmail.com";
    };
  };
}
