---@type vim.lsp.Config
-- Requiere instalación manual: brew install nixd
-- O via nix:  nix profile install nixpkgs#nixd
return {
  cmd = { 'nixd' },

  filetypes = { 'nix' },

  root_markers = {
    'flake.nix',
    'flake.lock',
    '.git',
    'default.nix',
    'shell.nix',
  },

  settings = {
    nixd = {
      nixpkgs = {
        -- Expresión para cargar nixpkgs. Ajustar si usas un flake propio:
        -- expr = '(builtins.getFlake "/ruta/al/flake").inputs.nixpkgs { }',
        expr = 'import <nixpkgs> { }',
      },

      formatting = {
        -- Elige el formateador que tengas instalado: alejandra | nixfmt | nixpkgs-fmt
        command = { 'alejandra' },
      },

      -- Opciones para autocompletado de módulos NixOS / home-manager.
      -- Descomenta y ajusta las rutas a tu flake:
      --
      -- options = {
      --   nixos = {
      --     expr = '(builtins.getFlake "/ruta/al/flake").nixosConfigurations.<hostname>.options',
      --   },
      --   home_manager = {
      --     expr = '(builtins.getFlake "/ruta/al/flake").homeConfigurations.<user>.options',
      --   },
      --   nix_darwin = {
      --     expr = '(builtins.getFlake "/ruta/al/flake").darwinConfigurations.<hostname>.options',
      --   },
      -- },
    },
  },
}
