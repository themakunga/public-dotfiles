local M = {}

-- Abre una ventana flotante con un buffer markdown y ejecuta cmd de forma async.
-- El contenido se vuelca al buffer cuando termina el proceso, luego se activa
-- el filetype 'markdown' para que markview renderice sobre el resultado final.
local function run_to_md_buffer(cmd_args, title)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = true

  local win_width = math.floor(vim.o.columns * 0.60)
  local win_height = math.floor(vim.o.lines * 0.80)
  local row = math.floor((vim.o.lines - win_height) / 2)
  local col = math.floor((vim.o.columns - win_width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = win_width,
    height = win_height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = ' ' .. (title or '󰋦 Claude') .. ' ',
    title_pos = 'center',
  })

  -- Cerrar con q
  vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = buf, silent = true, desc = 'Cerrar panel AI' })

  -- Placeholder de carga (sin filetype todavía para que markview no se active en vacío)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { '⏳ Consultando…' })

  local output = {}
  local stderr_lines = {}

  vim.fn.jobstart(cmd_args, {
    stdout_buffered = true,
    stderr_buffered = true,

    on_stdout = function(_, data)
      if data then
        vim.list_extend(output, data)
      end
    end,

    on_stderr = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= '' then
            table.insert(stderr_lines, line)
          end
        end
      end
    end,

    on_exit = function(_, code)
      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(buf) then
          return
        end

        if code ~= 0 and #stderr_lines > 0 then
          vim.list_extend(output, { '', '---', '> ⚠️ stderr:' })
          for _, l in ipairs(stderr_lines) do
            table.insert(output, '> ' .. l)
          end
        end

        -- Quitar líneas vacías finales
        while #output > 0 and output[#output] == '' do
          table.remove(output)
        end

        vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)
        vim.bo[buf].modified = false

        -- Activar filetype DESPUÉS del contenido para que markview renderice el resultado final
        vim.bo[buf].filetype = 'markdown'

        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_set_cursor(win, { 1, 0 })
        end
      end)
    end,
  })

  return buf, win
end

M.load = function()
  -- :ClaudeCapture <prompt>
  -- Ejecuta `claude -p "<prompt>"` y muestra el resultado renderizado con markview
  CMD.usrcmd('ClaudeCapture', function(opts)
    local prompt = vim.trim(opts.args or '')
    if prompt == '' then
      Log.warn('ClaudeCapture: escribí un prompt — :ClaudeCapture tu pregunta aquí')
      return
    end
    run_to_md_buffer({ 'claude', '-p', prompt }, '󰋦 Claude')
  end, {
    nargs = '+',
    desc = 'Consulta rápida a Claude — respuesta en buffer Markdown (markview)',
  })

  -- :[range]ClaudeCaptureSend [instrucción]
  -- Envía la selección visual como contexto; la instrucción es opcional
  CMD.usrcmd('ClaudeCaptureSend', function(opts)
    local start_l = opts.line1
    local end_l = opts.line2
    local lines = vim.api.nvim_buf_get_lines(0, start_l - 1, end_l, false)
    local selection = table.concat(lines, '\n')

    local instruction = vim.trim(opts.args or '')
    if instruction == '' then
      instruction = 'Explain this:'
    end

    local ft = vim.bo.filetype
    local fence = ft ~= '' and ('```' .. ft) or '```'
    local full_prompt = instruction .. '\n\n' .. fence .. '\n' .. selection .. '\n```'

    run_to_md_buffer({ 'claude', '-p', full_prompt }, '󰋦 Claude')
  end, {
    nargs = '*',
    range = true,
    desc = 'Envía selección a Claude — respuesta en buffer Markdown (markview)',
  })

  -- Keymaps bajo el namespace <leader>A (AI) — coherente con claude-code.lua
  KM.bulk_map({
    {
      mode = 'n',
      motion = '<leader>Aq',
      cmd = ':ClaudeCapture ',
      opts = { desc = 'Claude: query rápido (markdown)' },
    },
    {
      mode = 'v',
      motion = '<leader>Aq',
      cmd = ':ClaudeCaptureSend ',
      opts = { desc = 'Claude: enviar selección (markdown)' },
    },
  })
end

return M
