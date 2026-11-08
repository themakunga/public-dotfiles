local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/phrmendes/todotxt.nvim' },
  })

  if not Checker.check({ 'todotxt' }) then
    return
  end

  require('todotxt').setup({})

  local namespace = vim.api.nvim_create_namespace('todotxt_checkboxes')
  local group = vim.api.nvim_create_augroup('TodoTxtCheckboxes', { clear = true })
  local function render(event)
    local buf = event.buf
    if vim.bo[buf].filetype ~= 'todotxt' then
      return
    end
    vim.api.nvim_buf_clear_namespace(buf, namespace, 0, -1)
    for row, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
      if line:find('%S') then
        local done = require('todotxt.task').is_completed(line)
        vim.api.nvim_buf_set_extmark(buf, namespace, row - 1, 0, {
          virt_text = { { done and '☑ ' or '☐ ', done and 'DiagnosticOk' or 'Comment' } },
          virt_text_pos = 'inline',
        })
      end
    end
  end

  vim.api.nvim_create_autocmd({ 'BufEnter', 'TextChanged', 'TextChangedI' }, {
    group = group,
    callback = render,
  })
  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = 'todotxt',
    callback = function(event)
      vim.keymap.set('n', '<leader>td', function()
        if vim.api.nvim_get_current_line():find('%S') then
          require('todotxt').toggle_todo_state()
          render(event)
        end
      end, { buffer = event.buf, desc = 'Toggle task completion' })
      render(event)
    end,
  })
end

return M
