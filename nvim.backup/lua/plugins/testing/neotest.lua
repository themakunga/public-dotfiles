local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/nvim-neotest/nvim-nio' },
    { src = 'https://github.com/nvim-neotest/neotest-plenary' },
    { src = 'https://github.com/marilari88/neotest-vitest' },
    { src = 'https://github.com/fredrikaverpil/neotest-golang' },
    { src = 'https://github.com/nvim-neotest/neotest-python' },
    { src = 'https://github.com/nvim-neotest/neotest' },
  })

  ---@module 'neotest'
  local ok, neotest = pcall(require, 'neotest')

  if not ok then
    vim.notify('[CHECK REQUIRE FAILED] neotest ' .. debug.getinfo(2).source, vim.log.levels.WARN)
    return
  end

  local neotest_ns = vim.api.nvim_create_namespace('neotest')
  vim.diagnostic.config({
    virtual_text = {
      format = function(diagnostic)
        local message = diagnostic.message:gsub('\n', ' '):gsub('\t', ' '):gsub('%s+', ' '):gsub('^%s+', '')
        return message
      end,
    },
  }, neotest_ns)

  local opts = {
    adapters = {
      require('neotest-plenary'),
      require('neotest-vitest'),
      require('neotest-golang'),
      require('neotest-python'),
    },
    status = { virtual_text = true },
    output = { open_on_run = true },
    quickfix = {
      open = function()
        local ok_trouble, trouble = pcall(require, 'trouble')
        if ok_trouble then
          trouble.open({ mode = 'quickfix', focus = false })
        end
      end,
    },
    consumers = {
      -- Refresh and auto close trouble after running tests
      trouble = function(client)
        client.listeners.results = function(adapter_id, results, partial)
          if partial then
            return
          end
          local tree = assert(client:get_position(nil, { adapter = adapter_id }))

          local failed = 0
          for pos_id, result in pairs(results) do
            if result.status == 'failed' and tree:get_key(pos_id) then
              failed = failed + 1
            end
          end
          vim.schedule(function()
            local ok_trouble, trouble = pcall(require, 'trouble')
            if ok_trouble and trouble.is_open() then
              trouble.refresh()
              if failed == 0 then
                trouble.close()
              end
            end
          end)
        end
        return {}
      end,
    },
  }

  neotest.setup(opts)

  -- Keymaps
  vim.keymap.set('n', '<leader>tt', function()
    neotest.run.run(vim.fn.expand('%'))
  end, { desc = 'Run File (Neotest)' })
  vim.keymap.set('n', '<leader>tT', function()
    neotest.run.run(vim.uv.cwd())
  end, { desc = 'Run All Test Files (Neotest)' })
  vim.keymap.set('n', '<leader>tr', function()
    neotest.run.run()
  end, { desc = 'Run Nearest (Neotest)' })
  vim.keymap.set('n', '<leader>tl', function()
    neotest.run.run_last()
  end, { desc = 'Run Last (Neotest)' })
  vim.keymap.set('n', '<leader>ts', function()
    neotest.summary.toggle()
  end, { desc = 'Toggle Summary (Neotest)' })
  vim.keymap.set('n', '<leader>to', function()
    neotest.output.open({ enter = true, auto_close = true })
  end, { desc = 'Show Output (Neotest)' })
  vim.keymap.set('n', '<leader>tO', function()
    neotest.output_panel.toggle()
  end, { desc = 'Toggle Output Panel (Neotest)' })
  vim.keymap.set('n', '<leader>tS', function()
    neotest.run.stop()
  end, { desc = 'Stop (Neotest)' })
  vim.keymap.set('n', '<leader>tw', function()
    neotest.watch.toggle(vim.fn.expand('%'))
  end, { desc = 'Toggle Watch (Neotest)' })
end

return M
