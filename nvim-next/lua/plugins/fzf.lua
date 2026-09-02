local M = {}

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


M.plugin = function()
  vim.pack.add({
     { src = 'https://github.com/ibhagwan/fzf-lua' },
  })


  if not Checker.check("fzf-lua") then
    return
  end

  local opts = {
    files = {
      fd_opts = '--color=never --type f --hidden --follow --exclude .git',
    },
    grep = {
      rg_opts = '--column --line-number --hidden -g "!.git"',
    },
  }


  require("fzf-lua").setup(opts)
  require("fzf-lua").register_ui_select()

  CMD.aucmd('fzf-command', {
    {
    event = 'FileType',
    pattern = "fzfg",
    callback = function(args)
      local km_opts = { buffer = args.buf, nowait = true }

      KM.bulk_map({
        { mode = "t", motion = "<C-j>",  cmd = "<C-j>" , opts = km_opts},
        { mode = "t", motion = "<C-k>",  cmd = "<C-k>" , opts = km_opts},
      })
    end,
    },
  })

  KM.bulk_map({
    {motion = "<leader>,", cmd = "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>", opts = {desc = "Switch Buffer"} },

    {motion = "<leader>fc", cmd = "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>", opts = {desc = "Buffers"}},
    {motion = "<leader>ff", cmd = "<cmd>FzfLua files<cr>", opts = {desc = "desc = 'Files'"}},
    {motion = "<leader><leader>", cmd = "<cmd>FzfLua files<cr>", opts = {desc = "Find Files"}},
    {motion = "<leader>fg", cmd = "<cmd>FzfLua git_files<cr>", opts = {desc = "Git-files"}},

    {motion = "<leader>s", cmd = "<cmd>FzfLua registers<cr>", opts = {desc = "Registers"}},
    {motion = "<leader>sa", cmd = "<cmd>FzfLua autocmds<cr>", opts = {desc = "Auto Commands"}},
    {motion = "<leader>sb", cmd = "<cmd>FzfLua grep_curbuf<cr>", opts = {desc = "Buffer"}},
    {motion = "<leader>sc", cmd = "<cmd>FzfLua command_history<cr>", opts = {desc = "Command History"}},
    {motion = "<leader>sC", cmd = "<cmd>FzfLua commands<cr>", opts = {desc = "Commands"}},
    {motion = "<leader>sd", cmd = "<cmd>FzfLua diagnostics_document<cr>", opts = {desc = "Document Diagnostics"}},
    {motion = "<leader>sD", cmd = "<cmd>FzfLua diagnostics_workspace<cr>", opts = {desc = "Workspace Diagnostics"}},
    {motion = "<leader>sg", cmd = "<cmd>FzfLua live_grep_native<cr>", opts = {desc = "Grep"}},
    {motion = "<leader>sh", cmd = "<cmd>FzfLua help_tags<cr>", opts = {desc = "Help Page"}},
    {motion = "<leader>sH", cmd = "<cmd>FzfLua highlights<cr>", opts = {desc = "Highlight Groups"}},
    {motion = "<leader>sj", cmd = "<cmd>FzfLua jumps<cr>", opts = {desc = "Jumplist"}},
    {motion = "<leader>sk", cmd = "<cmd>FzfLua keymaps<cr>", opts = {desc = "Key Maps"}},
    {motion = "<leader>sl", cmd = "<cmd>FzfLua loclist<cr>", opts = {desc = "Location List"}},
    {motion = "<leader>sM", cmd = "<cmd>FzfLua man_pages<cr>", opts = {desc = "Man Pages"}},
    {motion = "<leader>sm", cmd = "<cmd>FzfLua marks<cr>", opts = {desc = "Jump to Mark"}},
    {motion = "<leader>sR", cmd = "<cmd>FzfLua resume<cr>", opts = {desc = "Resume"}},
    {motion = "<leader>sq", cmd = "<cmd>FzfLua quickfix<cr>", opts = {desc = "Quickfix List"}},

    {motion = "<leader>ss", cmd = function() require('fzf-lua').lsp_document_symbols({ regex_filter = symbols_filter }) end, opts = {desc = "Symbol (Document)"}},
    {motion = "<leader>sS", cmd = function() require('fzf-lua').lsp_live_workspace_symbols({ regex_filter = symbols_filter }) end, opts = {desc = "Symbol (Workspace)"}},
  })
end

return M
