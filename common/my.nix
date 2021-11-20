{ config, lib, pkgs, ... }:

with lib;

{
  options.my = {
    user = mkOption { type = types.str; };
    name = mkOption { type = types.str; };
    email = mkOption { type = types.str; };
    uid = mkOption { type = types.int; };
  };
  config = {
    my = {
      user = "azuwis";
      name = "Zhong Jianxin";
      email = "azuwis@gmail.com";
      uid = 1000;
    };
  };
}
