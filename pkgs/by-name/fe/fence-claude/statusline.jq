#!/usr/bin/env -S jq -Mrf

((.cwd // .workspace.current_dir) | if startswith(env.HOME) then "~" + ltrimstr(env.HOME) else . end) as $cwd |
.model.id as $model |
((.context_window.used_percentage // 0) | floor | tostring + "%") as $usage |
"\($cwd) │ \($model)·\($usage)"
