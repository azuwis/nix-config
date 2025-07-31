{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.wrappers.git;
in

{
  options = {
    wrappers.git = {
      enable = lib.mkEnableOption "git, a distributed version control system";

      package = lib.mkPackageOption pkgs "git" {
        example = "gitFull";
      };

      config = lib.mkOption {
        type =
          with lib.types;
          let
            gitini = attrsOf (attrsOf anything);
          in
          either gitini (listOf gitini)
          // {
            merge =
              loc: defs:
              let
                config =
                  builtins.foldl'
                    (
                      acc:
                      { value, ... }@x:
                      acc
                      // (
                        if builtins.isList value then
                          {
                            ordered = acc.ordered ++ value;
                          }
                        else
                          {
                            unordered = acc.unordered ++ [ x ];
                          }
                      )
                    )
                    {
                      ordered = [ ];
                      unordered = [ ];
                    }
                    defs;
              in
              [ (gitini.merge loc config.unordered) ] ++ config.ordered;
          };
        default = [ ];
        example = {
          init.defaultBranch = "main";
          url."https://github.com/".insteadOf = [
            "gh:"
            "github:"
          ];
        };
        description = ''
          Configuration to write to /etc/gitconfig. A list can also be
          specified to keep the configuration in order. For example, setting
          `config` to `[ { foo.x = 42; } { bar.y = 42; }]` will put the `foo`
          section before the `bar` section unlike the default alphabetical
          order, which can be helpful for sections such as `include` and
          `includeIf`. See the CONFIGURATION FILE section of {manpage}`git-config(1)` for
          more information.
        '';
      };

      lfs = {
        enable = lib.mkEnableOption "git-lfs (Large File Storage)";

        package = lib.mkPackageOption pkgs "git-lfs" { };

        enablePureSSHTransfer = lib.mkEnableOption "Enable pure SSH transfer in server side by adding git-lfs-transfer to environment.systemPackages";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      environment.systemPackages = [
        (pkgs.wrapper {
          package = cfg.package;
          env.GIT_CONFIG_GLOBAL = pkgs.writeText "git-config-global" (
            lib.concatMapStringsSep "\n" lib.generators.toGitINI cfg.config
          );
        })
      ];
    })
    (lib.mkIf (cfg.enable && cfg.lfs.enable) {
      environment.systemPackages = lib.mkMerge [
        [ cfg.lfs.package ]
        (lib.mkIf cfg.lfs.enablePureSSHTransfer [ pkgs.git-lfs-transfer ])
      ];
      wrappers.git.config = {
        filter.lfs = {
          clean = "git-lfs clean -- %f";
          smudge = "git-lfs smudge -- %f";
          process = "git-lfs filter-process";
          required = true;
        };
      };
    })
  ];
}
