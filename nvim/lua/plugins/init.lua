local M = {}

-- 1. Dependencias globales a instalar primero
M.global_dependencies = {
  'https://github.com/MunifTanjim/nui.nvim',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-mini/mini.icons',
  'https://github.com/nvim-tree/nvim-web-devicons',
  'https://github.com/rcarriga/nvim-notify',
}

-- 2. Orden estricto y lógico: Primero motores, luego UI.
M.group_order = {
  'editor', -- Telescope, Treesitter, Lsp (Requeridos por la UI)
  'coding', -- Autocompletado (Blink)
  'formatter', -- Conform
  'git', -- Octo, Gitsigns
  'ui', -- Dashboard, Temas, Barra de estado (Cargan al final, cuando todo existe)
  'markdown',
  'testing',
}

-- 3. Listado de plugins ordenado lógicamente por dependencias internas
M.plugins_groups = {
  editor = {
    'treesitter', -- AST base (debe ir muy al principio)
    'nvim-treesitter', -- Contexto (depende de treesitter)
    'telescope', -- Buscador (Usado por Dashboard y Octo)
    'fzf', -- UI Select y buscador alternativo
    'lspconfig', -- Servidores y Mason
    'mini', -- Herramientas de texto
    'tmux',
    'toggle-term',
    'grug-far',
    'sort',
    'sops',
  },
  coding = {
    'blink', -- Motor de autocompletado rápido
    'autopairs',
    'mini-hipatterns',
  },
  formatter = {
    'conform',
  },
  git = {
    'gitsigns',
    'lazygit',
    'octo', -- Requiere Telescope
    'gitblame',
    'github-actions',
  },
  ui = {
    'tokyonight', -- Tema (Debe cargar antes que Lualine)
    'lualine-theme',
    'lualine',
    'snacks', -- DASHBOARD y Notificaciones
    'noice', -- UI de cmdline (Depende de notificaciones)
    'nvim-tree', -- Explorador de archivos
    'bufferline',
    'bafa',
    'dressing',
    'edgy',
    'colorizer',
    'comment',
    'log-highlight',
    'todo-comments',
    'trouble',
    'tuxedo',
    'ufo',
    'which-key', -- Atajos (Debe ir al final para detectar todos los mapeos de la UI)
  },
  markdown = {
    'rendermarkdown',
    'markdown-toc',
    'mardownpdf',
  },
  testing = {
    'neotest',
  },
}

M.init = function()
  -- PASO A: Instalar todas las dependencias globales primero
  for _, url in ipairs(M.global_dependencies) do
    vim.pack.add({
      { src = url },
    })
  end

  -- PASO B: Cargar los plugins respetando el orden de los grupos y de las listas
  for _, group_name in ipairs(M.group_order) do
    local plugins = M.plugins_groups[group_name]

    if plugins then
      for _, plugin_name in ipairs(plugins) do
        local module_name = 'plugins.' .. group_name .. '.' .. plugin_name

        local ok, plugin_module = pcall(require, module_name)

        if ok then
          if type(plugin_module) == 'table' and type(plugin_module.plugin) == 'function' then
            plugin_module.plugin()
          end
        else
          vim.notify(
            '[ERROR CARGANDO PLUGIN] No se pudo cargar: ' .. module_name .. '\nDetalle: ' .. tostring(plugin_module),
            vim.log.levels.ERROR
          )
        end
      end
    end
  end
end

return M
