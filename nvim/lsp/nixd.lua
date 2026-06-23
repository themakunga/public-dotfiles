---@type vim.lsp.Config

local options = {
  my_flake = {
    expr = '(builtins.getFlake "github:TheMakunga/nix-manager").nixosConfigurations.lsp-dummy-host.options',
  },
}

return {
  cmd = { 'nixd' },
  filetypes = { 'nix' },
  root_markers = { 'flake.nix', '.git' },
  settings = {
    nixd = {
      nixpkgs = {
        expr = 'import <nixpkgs> { }',
      },
      formatting = {
        command = { 'alejandra' },
      },
      options = options,
    },
  },
}
