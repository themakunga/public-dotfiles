local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/echasnovski/mini.icons' },
    { src = 'https://github.com/ibhagwan/fzf-lua' },
  })

  ---@module 'fzf-lua'
  local ok, fzf = pcall(require, 'fzf-lua')

  if not ok then
    vim.notify('[CHECK REQUIRE FAILED] fzf-lua ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  -- Limit document/workspace symbol pickers to meaningful kinds.
  local kind_filter = {
    default = {
      'Class',
      'Constructor',
      'Enum',
      'Field',
      'Function',
      'Interface',
      'Method',
      'Module',
      'Namespace',
      'Package',
      'Property',
      'Struct',
      'Trait',
    },
    markdown = false,
    help = false,
    lua = {
      'Class',
      'Constructor',
      'Enum',
      'Field',
      'Function',
      'Interface',
      'Method',
      'Module',
      'Namespace',
      -- "Package", -- luals uses it for control-flow structures
      'Property',
      'Struct',
      'Trait',
    },
  }

  local get_kind_filter = function(buf)
    buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
    local ft = vim.bo[buf].filetype

    if kind_filter[ft] == false then
      return
    end
    if type(kind_filter[ft]) == 'table' then
      return kind_filter[ft]
    end
    return type(kind_filter.default) == 'table' and kind_filter.default or nil
  end

  local symbols_filter = function(entry, ctx)
    if ctx.symbols_filter == nil then
      ctx.symbols_filter = get_kind_filter(ctx.bufnr) or false
    end
    if ctx.symbols_filter == false then
      return true
    end
    return vim.tbl_contains(ctx.symbols_filter, entry.kind)
  end

  local opts = {
    files = {
      fd_opts = '--color=never --type f --hidden --follow',
    },
    grep = {
      rg_opts = '--column --line-number --hidden',
    },
  }

  fzf.setup(opts)

  -- Route vim.ui.select (e.g. LSP code actions) through fzf-lua.
  fzf.register_ui_select()

  -- Keymaps
  -- Terminal mode mappings for fzf filetype
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'fzf',
    callback = function(args)
      vim.keymap.set('t', '<c-j>', '<c-j>', { buffer = args.buf, nowait = true })
      vim.keymap.set('t', '<c-k>', '<c-k>', { buffer = args.buf, nowait = true })
    end,
  })

  vim.keymap.set(
    'n',
    '<leader>,',
    '<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>',
    { desc = 'Switch Buffer' }
  )

  -- find
  vim.keymap.set('n', '<leader>fb', '<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>', { desc = 'Buffers' })
  vim.keymap.set('n', '<leader>ff', '<cmd>FzfLua files<cr>', { desc = 'Files' })
  vim.keymap.set('n', '<leader><space>', '<cmd>FzfLua files<cr>', { desc = 'Find Files' })
  vim.keymap.set('n', '<leader>fg', '<cmd>FzfLua git_files<cr>', { desc = 'Git-files' })

  -- search
  vim.keymap.set('n', '<leader>s"', '<cmd>FzfLua registers<cr>', { desc = 'Registers' })
  vim.keymap.set('n', '<leader>sa', '<cmd>FzfLua autocmds<cr>', { desc = 'Auto Commands' })
  vim.keymap.set('n', '<leader>sb', '<cmd>FzfLua grep_curbuf<cr>', { desc = 'Buffer' })
  vim.keymap.set('n', '<leader>sc', '<cmd>FzfLua command_history<cr>', { desc = 'Command History' })
  vim.keymap.set('n', '<leader>sC', '<cmd>FzfLua commands<cr>', { desc = 'Commands' })
  vim.keymap.set('n', '<leader>sd', '<cmd>FzfLua diagnostics_document<cr>', { desc = 'Document Diagnostics' })
  vim.keymap.set('n', '<leader>sD', '<cmd>FzfLua diagnostics_workspace<cr>', { desc = 'Workspace Diagnostics' })
  vim.keymap.set('n', '<leader>sg', '<cmd>FzfLua live_grep_native<cr>', { desc = 'Grep' })
  vim.keymap.set('n', '<leader>sh', '<cmd>FzfLua help_tags<cr>', { desc = 'Help Pages' })
  vim.keymap.set('n', '<leader>sH', '<cmd>FzfLua highlights<cr>', { desc = 'Highlight Groups' })
  vim.keymap.set('n', '<leader>sj', '<cmd>FzfLua jumps<cr>', { desc = 'Jumplist' })
  vim.keymap.set('n', '<leader>sk', '<cmd>FzfLua keymaps<cr>', { desc = 'Key Maps' })
  vim.keymap.set('n', '<leader>sl', '<cmd>FzfLua loclist<cr>', { desc = 'Location List' })
  vim.keymap.set('n', '<leader>sM', '<cmd>FzfLua man_pages<cr>', { desc = 'Man Pages' })
  vim.keymap.set('n', '<leader>sm', '<cmd>FzfLua marks<cr>', { desc = 'Jump to Mark' })
  vim.keymap.set('n', '<leader>sR', '<cmd>FzfLua resume<cr>', { desc = 'Resume' })
  vim.keymap.set('n', '<leader>sq', '<cmd>FzfLua quickfix<cr>', { desc = 'Quickfix List' })

  vim.keymap.set('n', '<leader>ss', function()
    fzf.lsp_document_symbols({ regex_filter = symbols_filter })
  end, { desc = 'Symbol (Document)' })

  vim.keymap.set('n', '<leader>sS', function()
    fzf.lsp_live_workspace_symbols({ regex_filter = symbols_filter })
  end, { desc = 'Symbol (Workspace)' })
end

return M
