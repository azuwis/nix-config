{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.jujutsu;
in
{
  options.my.jujutsu = {
    enable = mkEnableOption "jujutsu";
  };

  config = mkIf cfg.enable {
    my.lazyvim.jujutsu.enable = true;

    programs.jujutsu = {
      enable = true;
      settings = {
        aliases = {
          ld = [
            "log"
            "--template"
            "log_detailed"
          ];
          ls = [
            "log"
            "--template"
            "log_stat"
          ];
        };
        colors = {
          "diff removed token" = {
            underline = false;
          };
          "diff added token" = {
            underline = false;
          };
        };
        # https://martinvonz.github.io/jj/latest/templates/
        # https://github.com/martinvonz/jj/blob/main/cli/src/config/templates.toml
        template-aliases = {
          description_placeholder = ''label("description placeholder", "(no description)")'';
          log_custom = ''
            if(root,
              format_root_commit(self),
              label(if(current_working_copy, "working_copy"),
                concat(
                  separate(" ",
                    format_short_change_id_with_hidden_and_divergent_info(self),
                    format_short_signature(author),
                    format_timestamp(committer.timestamp()),
                    bookmarks,
                    tags,
                    working_copies,
                    git_head,
                    format_short_commit_id(commit_id),
                    if(conflict, label("conflict", "conflict")),
                  ) ++ "\n",
                  separate(" ",
                    if(empty, label("empty", "(empty)")),
                    if(description,
                      description.first_line(),
                      if(empty, label("empty", description_placeholder), diff.summary()),
                    ),
                  ),
                ),
              )
            )
          '';
          log_detailed = ''concat(builtin_log_detailed, diff.stat(120), "\n")'';
          log_stat = "concat(builtin_log_compact, diff.summary())";
        };
        templates = {
          log = "log_custom";
        };
        ui = {
          default-command = "log";
          diff-editor = [
            "nvim"
            "-c"
            "DiffEditor $left $right $output"
          ];
          diff-instructions = false;
        };
        user = {
          inherit (config.my) email name;
        };
      };
    };
  };
}
