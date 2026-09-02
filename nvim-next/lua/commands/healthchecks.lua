local M = {}

local function checkhealt_list()
  local providers = vim.fn.getcompletion('', 'health')

  vim.ui.select(providers, {
    prompt = 'Select a health provider:',
    format_item = function(item)
      return item:gsub('^health%?', ''):gsub('^provider%?', '')
    end,
  }, function(choice)
    if choice then
      local provider = choice:match('([^/]+)$')

      if provider then
        vim.cmd('checkhealth ' .. provider)
      else
        vim.cmd('checkhealth ' .. choice)
      end
    end
  end)
end

local function prompt_chechhealt()
  local provider = vim.fn.input('Health Provider (empty for full checkhealth): ')

  if provider and provider ~= '' then
    vim.cmd('checkhealth ' .. provider)
  else
    vim.cmd('checkhealth')
  end
end

M.load = function()
  local keymap = {
    mode = 'n',
    motion = '<leader>ch',
    cmd = ':CheckHealthPrompt<CR>',
    opts = { desc = 'Open CheckHealth Prompt' },
  }

  CMD.usrcmd('CheckHealthList', checkhealt_list, {})
  CMD.usrcmd('CheckHealthPrompt', prompt_chechhealt, {})

  KM.map(keymap)
end

return M
