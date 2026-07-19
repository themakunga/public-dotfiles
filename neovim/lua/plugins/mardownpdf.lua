local M = {}

M.plugin = function()
  vim.api.nvim_create_user_command('ConvertToPDF', function(opts)
    local current_file = vim.fn.expand('%:p')
    local current_file_extension = vim.fn.expand('%:e')
    local current_file_base = vim.fn.expand('%:r')

    local is_markdown_file = function()
      if vim.bo.filetype == 'markdown' then
        return true
      end

      local md_extensions = { 'md', 'markdown', 'mkd', 'mdown', 'mdwn' }

      for _, ext in ipairs(md_extensions) do
        if current_file_extension == ext then
          return true
        end
      end

      return false
    end

    if not is_markdown_file() then
      vim.notify('Only markdown files can be converted to PDF', vim.log.levels.WARN)
      return
    end

    if current_file == '' then
      vim.nofiy('A valid file must be saved in the current directory, do you save it?', vim.log.levels.WARN)
      return
    end

    if vim.fn.executable('pandoc') == 0 then
      vim.notify('Error!: Pandoc must be installed in system', vim.log.levels.ERROR)
      return
    end

    local config = {
      input = current_file,
      output = current_file_base .. '.pdf',
      engine = 'xelatex',
      margin = '2.0cm',
      font = 'DejaVu Serif',
      highlight = 'tango',
      toc = false,
      toc_depth = 3,
      numbered_sections = true,
      color_link = true,
    }

    if opts.args and opts.args ~= '' then
      local args = vim.split(opts.args, '%s+')
      for i = 1, #args do
        if args[i] == '--engine' and args[i + 1] then
          config.engine = args[i + 1]
        elseif args[i] == '--output' and args[i + 1] then
          config.output = args[i + 1]
        elseif args[i] == '--margin' and args[i + 1] then
          config.margin = args[i + 1]
        elseif args[i] == '--font' and args[i + 1] then
          config.font = args[i + 1]
        elseif args[i] == '--no-toc' then
          config.toc = false
        elseif args[i] == '--no-numbers' then
          config.numbered_sections = false
        end
      end
    end

    local cmd = {
      'pandoc',
      config.input,
      '-o',
      config.output,
      '--pdf-engine=' .. config.engine,
      '-V',
      'geometry:margin=' .. config.margin,
      '-V',
      'mainfont=' .. config.font,
      '--highlight-style',
      config.highlight,
    }
    if config.toc then
      table.insert(cmd, '--toc')
      table.insert(cmd, '--toc-depth=' .. config.toc_depth)
    end

    if config.numbered_sections then
      table.insert(cmd, '--number-sections')
    end

    if config.color_links then
      table.insert(cmd, '-V')
      table.insert(cmd, 'colorlinks=true')
      table.insert(cmd, '-V')
      table.insert(cmd, 'linkcolor=blue')
      table.insert(cmd, '-V')
      table.insert(cmd, 'urlcolor=blue')
    end

    if config.engine == 'xelatex' and vim.fn.executable('xelatex') == 0 then
      vim.notify('⚠️  XeLaTeX not found, changing now to pdflatext', vim.log.levels.WARN)
      cmd[6] = '--pdf-engine=pdflatex'
      config.engine = 'pdflatex'
    end

    print('=== Conversion Config ===')
    print('Input: ' .. config.input)
    print('Output: ' .. config.output)
    print('PDF Engine: ' .. config.engine)
    print('Margin: ' .. config.margin)
    print('Font: ' .. config.font)
    print('=' .. string.rep('=', 30))

    local start_time = os.time()
    local notification = vim.notify('🔄 Generanting PDF with ' .. config.engine .. '...', vim.log.levels.INFO, {
      title = 'Pandoc',
      timeout = false,
    })

    vim.fn.jobstart(cmd, {
      on_exit = function(_, exit_code, _)
        local elapsed = os.time() - start_time

        if notification then
          ---@diagnostic disable-next-line:param-type-mismatch
          vim.notify(nil, vim.log.levels.INFO, { id = notification })
        end

        if exit_code == 0 then
          local message = string.format('PDF Generated in %d seconds\n %s', elapsed, config.output)
          vim.notify(message, vim.log.levels.INFO, {
            title = 'Success!',
            on_open = function(win)
              local buf = vim.api.nvim_win_get_buf(win)
              vim.keymap.set('n', '<CR>', function()
                vim.cmd('silent !xdg-open ' .. vim.fn.shellescape(config.output) .. ' &')
                vim.api.nvim_win_close(win, true)
              end, { buffer = buf, desc = 'Open PDF' })

              vim.keymap.set('n', 'o', function()
                vim.cmd('silent !xdg-open ' .. vim.fn.shellescape(config.output) .. ' &')
                vim.api.nvim_win_close(win, true)
              end, { buffer = buf, desc = 'Open PDF' })

              vim.keymap.set('n', 'r', function()
                vim.api.nvim_win_close(win, true)
                vim.cmd('ConvertToPDF' .. opts.args)
              end, { buffer = buf, desc = 'Regenerate PDF' })

              vim.keymap.set('n', 'd', function()
                os.remove(config.output)
                vim.notify('PDF deleted!' .. config.output, vim.log.levels.INFO)
                vim.api.nvim_win_close(win, true)
              end, { buffer = buf, desc = 'Delete PDF' })

              vim.keymap.set('n', 'q', function()
                vim.api.nvim_win_close(win, true)
              end, { buffer = buf, desc = 'Close' })
            end,
          })
        else
          vim.notify('Error on convertion, code: ' .. exit_code, vim.log.levels.ERROR, { title = 'Pandoc Error' })
        end
      end,

      on_stderr = function(_, data, _)
        for _, line in ipairs(data) do
          if line ~= '' and not line:find('^$s*$') then
            vim.notify('Pandoc: ' .. line, vim.log.levels.WARN)
          end
        end
      end,
    })

    --- je
  end, {
    desc = 'Convert Markdown to PDF using PANDOC',
    bang = true,
    nargs = '*',
    complete = function(ArgLead, CmdLine, CursorPos)
      local suggestions = {
        '--engine=xelatex',
        '--engine=pdflatex',
        '--engine=lualatex',
        '--output=',
        '--margin=2cm',
        '--margin=2.5cm',
        '--margin=3cm',
        '--font=DejaVu Serif',
        '--font=Helvetica',
        '--font=Times New Roman',
        '--no-toc',
        '--no-numbers',
        '--help',
      }

      return vim.tbl_filter(function(item)
        return item:find(ArgLead, 1, true) == 1
      end, suggestions)
    end,
  })

  vim.keymap.set(
    'n',
    '<leader>mc',
    ':ConvertToPDF<cr>',
    { desc = 'Convert current buffer to PDF if extension is markdown' }
  )

  vim.keymap.set('n', '<leader>mC', ':ConvertToPDF!<cr>', { desc = 'Force Convert current buffeer to PDF' })
end

return M
