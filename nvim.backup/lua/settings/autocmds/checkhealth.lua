local M = {}

M.load = function()
  -- list of availables checklist
  vim.api.nvim_create_user_command('CheckHealthList', function()
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
  end, {})
  -- prompt checkhealth
  vim.api.nvim_create_user_command('CheckHealthPrompt', function()
    local provider = vim.fn.input('Health Provider (empty for full checkhealth): ')

    if provider and provider ~= '' then
      vim.cmd('checkhealth ' .. provider)
    else
      vim.cmd('checkhealth')
    end
  end, {})
  vim.keymap.set('n', '<leader>ch', ':CheckHealthPrompt<cr>', { desc = 'Open CheckHealth Prompt' })
end

return M
