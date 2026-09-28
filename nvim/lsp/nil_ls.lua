---@type vim.lsp.Config
-- LSP alternativo para Nix, disponible via Mason (paquete: "nil")
-- O manualmente: brew install nil
return {
  cmd = { 'nil' },

  filetypes = { 'nix' },

  root_markers = {
    'flake.nix',
    'flake.lock',
    '.git',
    'default.nix',
    'shell.nix',
  },

  settings = {
    ['nil'] = {
      formatting = {
        -- Elige el formateador instalado: alejandra | nixfmt | nixpkgs-fmt
        command = { 'alejandra' },
      },

      nix = {
        flake = {
          -- Habilita soporte de Nix Flakes
          autoEvalInputs = true,
        },
      },

      diagnostics = {
        ignored = {},
        excludedFiles = {},
      },
    },
  },
}
