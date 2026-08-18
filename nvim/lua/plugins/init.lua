--- Archivo: ./lua/plugins/init.lua
local M = {}

-- 1. Dependencias globales (se instalan una sola vez)
M.global_dependencies = {
  'https://github.com/MunifTanjim/nui.nvim',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-mini/mini.icons',
  'https://github.com/nvim-tree/nvim-web-devicons',
  'https://github.com/rcarriga/nvim-notify',
}

-- 2. Sistema de Carga Diferida (Lazy Loading) por eventos
M.lazy_groups = {
  -- UI Base (Carga instantánea)
  immediate = {
    'ui.tokyonight',
  },

  -- Cuando la interfaz está lista
  vimenter = {
    'ui.lualine-theme',
    'ui.lualine',
    'ui.snacks',
    'ui.noice',
    'ui.nvim-tree',
    'ui.bufferline',
    'ui.bafa',
    'ui.colorizer',
    'ui.which-key',
    'ui.libre-view',
  },

  -- Antes de leer un archivo (LSP, Git, Herramientas pesadas)
  bufread = {
    'editor.treesitter',
    'editor.nvim-treesitter',
    'editor.fzf',
    'editor.lspconfig',
    'editor.mini',
    'editor.sort',
    'editor.sops',
    'editor.toggle-term',
    'formatter.conform',
    'git.gitsigns',
    'git.octo',
    'git.gitblame',
    'git.lazygit',
    'git.github-actions',
    'ui.todo-comments',
    'ui.trouble',
    'ui.ufo',
    'ui.comment',
    'testing.neotest',
  },

  -- Al empezar a escribir (Autocompletado)
  insertenter = {
    'coding.cmp',
    'coding.autopairs',
    'coding.mini-hipatterns',
  },

  -- Específicos por tipo de archivo
  markdown = {
    'markdown.rendermarkdown',
    'markdown.markdown-toc',
    'markdown.mardownpdf',
  },

  swift = {
    'coding.ios-dev',
  },
}

local function load_plugin(module_name)
  local ok, plugin_module = pcall(require, 'plugins.' .. module_name)
  if ok and type(plugin_module) == 'table' and type(plugin_module.plugin) == 'function' then
    plugin_module.plugin()
  else
    if not ok then
      vim.notify('[ERROR CARGANDO PLUGIN] ' .. module_name, vim.log.levels.ERROR)
    end
  end
end

M.init = function()
  -- A: Instalar globales
  for _, url in ipairs(M.global_dependencies) do
    vim.pack.add({ { src = url } })
  end

  -- B: Carga inmediata
  for _, plugin in ipairs(M.lazy_groups.immediate) do
    load_plugin(plugin)
  end

  -- C: Autocommands para carga diferida
  local autocmd = vim.api.nvim_create_autocmd

  autocmd('VimEnter', {
    once = true,
    callback = function()
      for _, plugin in ipairs(M.lazy_groups.vimenter) do
        load_plugin(plugin)
      end
    end,
  })

  autocmd({ 'BufReadPre', 'BufNewFile' }, {
    once = true,
    callback = function()
      for _, plugin in ipairs(M.lazy_groups.bufread) do
        load_plugin(plugin)
      end
    end,
  })

  autocmd('InsertEnter', {
    once = true,
    callback = function()
      for _, plugin in ipairs(M.lazy_groups.insertenter) do
        load_plugin(plugin)
      end
    end,
  })

  autocmd('FileType', {
    pattern = 'markdown',
    once = true,
    callback = function()
      for _, plugin in ipairs(M.lazy_groups.markdown) do
        load_plugin(plugin)
      end
    end,
  })
end

return M
