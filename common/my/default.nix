{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  options.my = {
    user = mkOption { type = types.str; };
    name = mkOption { type = types.str; };
    email = mkOption { type = types.str; };
    uid = mkOption { type = types.int; };
    keys = mkOption { type = types.listOf types.singleLineStr; };
    domain = mkOption { type = types.str; };
    ca = mkOption { type = types.path; };
  };
  config = {
    my = {
      inherit (inputs.my) domain;
      user = "azuwis";
      name = "Zhong Jianxin";
      email = "azuwis@gmail.com";
      uid = 1000;
      keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDBa4stB3iashVWVH3XA4CgciZ7UvnvMCNyc7nkKqpiqMs1TQNg+dayNv+rX6zJh+WEWL4bZ5SNr+cnlHpF6wCcZlicFh7vli4FKK0DgmcASJPRHqN98dBQ9aH+4ZIUcjuPaAPeA/0EO+o8RVNTCnOD3QtJjNPh6Kr1FW2THE+AMpdotnS5pUpH4hrFaaEhRkvOwUeaJ/kxs+KYqPTyq4pNyoSuG6aTzjwCpTJB1tbma+7/t8809Cpy6q48jh2VhB6Sb6sxcFi3KMo/i6I7SpmhlgPTEBDDtloQaP7uhgtkP7UTCldUU2UV8BrAXIRFHBccan1La2MJ3Z5vrr67zSkb"
      ];
      ca = ./ca.crt;
    };
  };
}
