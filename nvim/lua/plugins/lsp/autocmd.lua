local M = {}

M.load = function()
  local aucmd = vim.api.nvim_create_autocmd
  local map = vim.keymap.set
  -- enable autocomplete

  aucmd('LspAttach', {
    callback = function(ev)
      local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))

      if client:supports_method('textDocument/completion') then
        vim.opt.completeopt = {
          'menu',
          'menuone',
          'noinsert',
          'fuzzy',
          'popup',
        }

        vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
        map('i', '<Alt-space>', function()
          local col = vim.fn.col('.') - 1
          local line = vim.fn.getline('.')
          local char_before = line:sub(col, col)

          if char_before:match('[/%s%.~]') then
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-x><C-f>', true, true, true), 'n', true)
          else
            vim.lsp.completion.trigger()
          end
        end, { buffer = ev.buf, desc = 'LSP/path completion' })
      end
      require('plugins.lsp.keymaps').lspKeymapsAttached(ev.buf)
    end,
  })
  -- autoformat (Generic)
  aucmd('BufWritePre', {
    pattern = '*',
    callback = function(event)
      local buf = event.buf
      local buff_type = vim.bo[buf].buftype

      if buff_type ~= '' and buff_type ~= 'acwrite' then
        return
      end

      if vim.b[buf].format_disable then
        return
      end

      local clients = vim.lsp.get_clients({ bufnr = buf })

      for _, client in ipairs(clients) do
        if client:supports_method('textDocument/formatting') then
          local success, err = pcall(vim.lsp.buf.format, {
            async = false,
            timeout_ms = 2000,
            bufnr = buf,
            filter = function(format_client)
              return format_client.name ~= 'null-ls' -- Filter out null-ls if needed
            end,
          })

          if not success then
            vim.notify('Error on LSP formatting: ' .. err, vim.log.levels.ERROR)
          end
          break
        end
      end
    end,
  })
  -- Nginx AutoFormat
  aucmd('BufWritePre', {
    group = vim.api.nvim_create_augroup('NginxAutoFormat', { clear = true }),
    pattern = { '*.nginx', '*.conf', 'nginx.conf', '*.vhost' },
    callback = function(args)
      local bufnr = args.buf
      local clients = vim.lsp.get_clients({ bufnr = bufnr })

      for _, client in ipairs(clients) do
        if client.name == 'efm' then
          vim.lsp.buf.format({
            filter = function(buf)
              return buf.name == 'efm'
            end,
            async = false,
            bufnr = bufnr,
          })
          break
        end
      end
    end,
  })

  -- AWS / Elastic Beanstalk filetype detection
  aucmd({ 'BufRead', 'BufNewFile' }, {
    pattern = {
      '*./platform/*',
      '*/.ebextensions/*',
      '*.config',
      '*.ebextensions',
    },
    callback = function()
      local filename = vim.fn.expand('%:p')

      if string.find(filename, '/%.platform/') or string.find(filename, '/%.ebextensions/') then
        if string.match(filename, '%.config$') then
          vim.bo.filetype = 'yaml'
        end
      end
    end,
  })
end

return M
