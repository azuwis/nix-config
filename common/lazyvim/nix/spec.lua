local uv = vim.uv

local dir
if uv.fs_stat("/etc/nixos") then
  dir = "/etc/nixos"
else
  dir = vim.fn.expand("~/.config/nixpkgs")
end

local hostname = uv.os_gethostname()

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
                  expr = string.format("(import %s).nixosConfigurations.%s.options", dir, hostname),
                },
                ["nix-darwin"] = {
                  expr = string.format("(import %s).darwinConfigurations.%s.options", dir, hostname),
                },
                ["home-manager"] = {
                  expr = string.format("(import %s).homeConfigurations.%s.options", dir, os.getenv("USER")),
                },
              },
            },
          },
        },
      },
    },
  },
}
