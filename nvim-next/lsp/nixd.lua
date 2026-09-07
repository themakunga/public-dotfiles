---@type vim.lsp.Config
return {
  cmd = { 'nixd' },

  filetypes = {
    'nix',
  },

  root_markers = {
    'flake.nix',
    'default.nix',
    'shell.nix',
    '.git',
  },

  settings = {
    nixd = {
      nixpkgs = {
        expr = 'import <nixpkgs> { }',
      },

      formatting = {
        command = {
          'nixfmt',
        },
      },

      options = {
        nixos = {
          expr = '(builtins.getFlake (builtins.toString ./.)).nixosConfigurations.<hostname>.options',
        },

        ['home-manager'] = {
          expr = '(builtins.getFlake (builtins.toString ./.)).homeConfigurations.<username>.options',
        },

        ['nix-darwin'] = {
          expr = '(builtins.getFlake (builtins.toString ./.)).darwinConfigurations.<hostname>.options',
        },
      },
    },
  },
}
