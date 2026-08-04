local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/kevinhwang91/promise-async' },
    { src = 'https://github.com/luukvbaal/statuscol.nvim' },
    { src = 'https://github.com/kevinhwang91/nvim-ufo' },
  })

  ---@module 'statuscol'
  local ok_statuscol, statuscol = pcall(require, 'statuscol')
  if not ok_statuscol then
    vim.notify('[CHECK REQUIRE FAILED] statuscol ' .. debug.getinfo(2).source, vim.log.levels.WARN)
  else
    local builtin = require('statuscol.builtin')
    statuscol.setup({
      relculright = true,
      segments = {
        { text = { builtin.foldfunc }, click = 'v:lua.ScFa' },
        { text = { '%s' }, click = 'v:lua.ScSa' },
        { text = { builtin.lnumfunc, ' ' }, click = 'v:lua.ScLa' },
      },
    })
  end

  -- Fold options required by UFO
  vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
  vim.o.foldcolumn = '1' -- '0' is not bad
  vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
  vim.o.foldlevelstart = 99
  vim.o.foldenable = true

  ---@module 'ufo'
  local ok_ufo, ufo = pcall(require, 'ufo')
  if not ok_ufo then
    vim.notify('[CHECK REQUIRE FAILED] ufo ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  ufo.setup()

  -- Keymaps
  vim.keymap.set('n', 'zR', function()
    ufo.openAllFolds()
  end, { desc = 'Open all folds' })

  vim.keymap.set('n', 'zM', function()
    ufo.closeAllFolds()
  end, { desc = 'Close all folds' })

  vim.keymap.set('n', 'K', function()
    local winid = ufo.peekFoldedLinesUnderCursor()
    if not winid then
      vim.lsp.buf.hover()
    end
  end, { desc = 'Peek fold or hover' })
end

return M
