local uv = vim.uv

local dir
if uv.fs_stat("/etc/nixos") then
  dir = "/etc/nixos"
else
  dir = vim.fn.expand("~/.config/nixpkgs")
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        nixd = {
          settings = {
            nixd = {
              formatting = {
                command = { "nixfmt" },
              },
              options = {
                nixos = {
                  expr = string.format("(import %s { }).nixosConfigurations.nuc.options", dir),
                },
                ["nix-darwin"] = {
                  expr = string.format("(import %s { }).darwinConfigurations.mbp.options", dir),
                },
                ["home-manager"] = {
                  expr = string.format("(import %s { }).homeConfigurations.azuwis.options", dir),
                },
              },
            },
          },
        },
      },
    },
  },
}
