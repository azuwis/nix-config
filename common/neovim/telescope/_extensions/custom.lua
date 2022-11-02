return require("telescope").register_extension {
  exports = {
    find = function ()
      local dir = vim.fn.expand("%:p:h")
      local re = vim.regex([[roles/[^/]\+/\(defaults\|files\|handlers\|meta\|tasks\)]])
      if re:match_str(dir) then
        dir = vim.fn.expand("%:p:h:h")
      end
      local title = require("plenary.path"):new(dir):shorten()
      require("telescope.builtin").find_files({ prompt_title=title, cwd=dir })
    end,
  },
}
