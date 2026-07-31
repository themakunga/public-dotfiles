local M = {}

-- 1. Dependencias globales a instalar primero
M.global_dependencies = {
  'https://github.com/MunifTanjim/nui.nvim',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-mini/mini.icons',
  'https://github.com/nvim-tree/nvim-web-devicons',
  'https://github.com/rcarriga/nvim-notify',
}

-- 2. Orden estricto en el que se cargarán las carpetas (Lua lee las tablas sin orden fijo)
M.group_order = {
  'ui',
  'editor',
  'git',
  'markdown',
  'formatter',
  'coding',
  'testing', -- Añadido basándome en tu árbol de directorios
}

-- 3. Listado completo de plugins extraído de tu árbol de archivos
M.plugins_groups = {
  ui = {
    'bafa',
    'bufferline',
    'colorizer',
    'comment',
    'dressing',
    'edgy',
    'log-highlight',
    'lualine-theme',
    'lualine',
    'noice',
    'nvim-tree',
    'oil',
    'snacks',
    'todo-comments',
    'tokyonight',
    'trouble',
    'tuxedo',
    'ufo',
    'which-key',
  },
  editor = {
    'fzf',
    'grug-far',
    'lspconfig',
    'mini',
    'nvim-treesitter',
    'sops',
    'sort',
    'tmux',
    'toggle-term',
    'treesitter',
  },
  git = {
    'gitblame',
    'github-actions',
    'gitsigns',
    'lazygit',
    'octo',
  },
  markdown = {
    'mardownpdf', -- Escrito tal cual aparece en tu carpeta
    'markdown-toc',
    'rendermarkdown',
  },
  formatter = {
    'conform',
  },
  coding = {
    'autopairs',
    'cmp',
    'mini-hipatterns',
  },
  testing = {
    'neotest',
  },
}

M.call = function()
  -- PASO A: Instalar todas las dependencias globales primero
  for _, url in ipairs(M.global_dependencies) do
    vim.pack.add({
      { src = url },
    })
  end

  -- PASO B: Cargar los plugins respetando el orden de los grupos
  for _, group_name in ipairs(M.group_order) do
    local plugins = M.plugins_groups[group_name]

    if plugins then
      for _, plugin_name in ipairs(plugins) do
        local module_name = 'plugins.' .. group_name .. '.' .. plugin_name

        -- `require` ejecuta automáticamente cualquier código suelto en el archivo
        local ok, plugin_module = pcall(require, module_name)

        if ok then
          -- Verificamos de forma segura si devolvió una tabla y si tiene la función .plugin()
          if type(plugin_module) == 'table' and type(plugin_module.plugin) == 'function' then
            plugin_module.plugin()
          end
          -- Si no tiene .plugin(), no pasa nada. El archivo ya se cargó gracias al `require` de arriba.
        else
          -- Si el archivo no existe o tiene un error de sintaxis grave, te avisará
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
