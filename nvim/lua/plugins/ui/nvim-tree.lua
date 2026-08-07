--- Archivo: ./lua/plugins/ui/nvim-tree.lua
local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/nvim-tree/nvim-tree.lua' },
    { src = 'https://github.com/antosha417/nvim-lsp-file-operations' },
  })

  local ok_tree, nvimtree = pcall(require, 'nvim-tree')
  if not ok_tree then
    return
  end

  local ok_lsp_ops, lsp_file_operations = pcall(require, 'lsp-file-operations')
  if ok_lsp_ops then
    lsp_file_operations.setup()
  end

  -- Función personalizada para los atajos internos de NvimTree
  local function my_on_attach(bufnr)
    local api = require('nvim-tree.api')

    local function ops(desc)
      return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    -- Cargar los atajos por defecto primero para no perder la navegación básica (enter, flechas, etc)
    api.config.mappings.default_on_attach(bufnr)

    -- ==========================================
    -- TUS ATAJOS PERSONALIZADOS
    -- ==========================================

    -- Eliminar el atajo por defecto de 'e' (evita conflictos al renombrar)
    vim.keymap.del('n', 'e', { buffer = bufnr })

    -- Asignar 'e' (dentro del árbol) para cerrar el panel, completando la función de Toggle/Focus
    vim.keymap.set('n', 'e', api.tree.close, ops('Close Panel (Toggle)'))

    -- Gestión de archivos exacta a tu solicitud
    vim.keymap.set('n', 'r', api.fs.rename, ops('Rename'))
    vim.keymap.set('n', 'a', api.fs.create, ops('Create'))
    vim.keymap.set('n', 'd', api.fs.remove, ops('Delete'))
    vim.keymap.set('n', 'c', api.fs.copy.node, ops('Copy'))
    vim.keymap.set('n', 'x', api.fs.cut, ops('Cut / Move'))
    vim.keymap.set('n', 'p', api.fs.paste, ops('Paste'))

    -- Tus atajos anteriores de visualización
    vim.keymap.set('n', 'P', api.node.open.preview, ops('Preview'))
    vim.keymap.set('n', 's', api.node.open.vertical_no_picker, ops('Open Vertical'))
    vim.keymap.set('n', 'S', api.node.open.horizontal_no_picker, ops('Open Horizontal'))
  end

  local opts = {
    hijack_cursor = true,
    sync_root_with_cwd = true,
    on_attach = my_on_attach, -- Aquí inyectamos nuestros atajos
    view = {
      side = 'right',
      width = 40,
    },
    renderer = {
      highlight_git = true,
      indent_markers = { enable = false },
    },
    git = { enable = true },

    -- NUEVA CONFIGURACIÓN: Mostrar todo excepto .git
    filters = {
      dotfiles = false, -- Muestra archivos ocultos (.env, .config, etc)
      custom = { '^\\.git$' }, -- Oculta ESTRICTAMENTE la carpeta .git mediante Regex
    },
  }

  nvimtree.setup(opts)

  -- Lógica del Smart Toggle Global (Para usar <leader>e desde cualquier otro archivo)
  vim.keymap.set('n', '<leader>ee', function()
    local api = require('nvim-tree.api')

    if api.tree.is_visible() then
      if vim.bo.filetype == 'NvimTree' then
        api.tree.close()
      else
        api.tree.focus()
      end
    else
      api.tree.open()
    end
  end, { desc = 'Smart Toggle/Focus Explorer' })
end

return M
