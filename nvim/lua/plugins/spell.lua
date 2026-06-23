local M = {}

M.config = {
  enabled = false,
  -- Languages to use (e.g., 'en', 'es', 'fr'). Must be available on your system.
  languages = { 'en', 'es' },
  -- Base path for the custom dictionary file
  dict_path = vim.fn.expand('~/.spell/custom_dictionary'),
  ns_id = vim.api.nvim_create_namespace('spell_checking'),
  timer = nil,
  debounce_ms = 500,
  diagnostic_severity = vim.diagnostic.severity.HINT,
  user_group = nil, -- Autocmd group placeholder
}

--- Helper to get the correct, full dictionary file path.
local function get_spellfile_path()
  return M.config.dict_path .. '.add'
end

--- Checks if a word is correctly spelled using Vim's built-in spell checker.
--- Returns 1 if correct, 0 if incorrect.
--- @param word string
--- @return boolean
local function is_good_word(word)
  -- spellgoodword() returns 1 if the word is correct.
  return vim.fn.spellgoodword(word) == 1
end

M.update_spell_diagnostics = function()
  if not vim.wo.spell then
    vim.diagnostic.reset(M.config.ns_id)
    return
  end

  local buffer = vim.api.nvim_get_current_buf()
  vim.diagnostic.reset(M.config.ns_id, buffer)

  -- CRITICAL IMPROVEMENT: Explicitly enforce spell options on the buffer
  -- right before running the check, ensuring the context is correct.
  vim.bo.spelllang = table.concat(M.config.languages, ',')
  vim.bo.spellfile = get_spellfile_path()

  local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)

  local diagnostics = {}

  local word_pattern = '[%wáéíóúÁÉÍÓÚñÑüÜ-]+'

  for num, line in ipairs(lines) do
    local col = 1
    while true do
      local start_col, end_col = line:find(word_pattern, col)
      if not start_col then
        break
      end

      local word = line:sub(start_col, end_col)

      -- NEW LOGIC: Check if the word is NOT good
      if not is_good_word(word) then
        if not word:match('^%u+$') then
          table.insert(diagnostics, {
            lnum = num - 1,
            col = start_col - 1,
            end_lnum = num - 1,
            end_col = end_col,
            severity = M.config.diagnostic_severity,
            source = 'spell',
            message = 'Possible misspelled word: ' .. word,
            code = 'spell',
            user_data = { word = word },
          })
        end
      end
      col = end_col + 1
    end
  end
  vim.diagnostic.set(M.config.ns_id, buffer, diagnostics)
end

M.debounce_update = function()
  if not vim.wo.spell then
    return
  end

  if M.config.timer then
    M.config.timer:close()
  end

  M.config.timer = vim.loop.new_timer()
  M.config.timer:start(
    M.config.debounce_ms,
    0,
    vim.schedule_wrap(function()
      M.update_spell_diagnostics()
      M.config.timer:close()
      M.config.timer = nil
    end)
  )
end

M.toggle_spell = function()
  if vim.wo.spell then
    vim.wo.spell = false
    vim.diagnostic.reset(M.config.ns_id)
    vim.notify('Spell checking disabled', vim.log.levels.INFO, { title = 'SpellCheck' })
  else
    vim.wo.spell = true

    -- Set dictionary languages and custom spell file
    vim.bo.spelllang = table.concat(M.config.languages, ',')
    vim.bo.spellfile = get_spellfile_path()

    vim.notify('Spell checking enabled, languages: ' .. vim.bo.spelllang, vim.log.levels.INFO, { title = 'SpellCheck' })
    vim.schedule(M.update_spell_diagnostics)
  end
end

M.show_spell_status = function()
  if vim.wo.spell then
    local lang = vim.bo.spelllang
    local file = vim.bo.spellfile
    vim.notify(
      'Spell check enabled.\nLanguages: ' .. lang .. '\nDictionary: ' .. file,
      vim.log.levels.INFO,
      { title = 'SpellCheck' }
    )
  else
    vim.notify('Spell check disabled', vim.log.levels.INFO, { title = 'SpellCheck' })
  end
end

M.add_word_to_dictionary_from_cursor = function()
  if not vim.wo.spell then
    vim.notify('Activate spell checking first', vim.log.levels.WARN, { title = 'SpellCheck' })
    return
  end

  local word = vim.fn.expand('<cword>')
  if word == '' then
    vim.notify('No word under cursor', vim.log.levels.WARN, { title = 'SpellCheck' })
    return
  end

  M.update_dictionary(word)
end

M.add_word_to_dictionary_custom = function()
  if not vim.wo.spell then
    vim.notify('Activate spell checking first', vim.log.levels.WARN, { title = 'SpellCheck' })
    return
  end

  local word = vim.fn.input('Add custom word to dictionary: ')
  if word ~= '' then
    M.update_dictionary(word)
  end
end

M.add_from_diagnostics = function()
  local diagnostics = vim.diagnostic.get(0, { namespace = M.config.ns_id })

  if #diagnostics == 0 then
    vim.notify('No spelling errors found in this buffer', vim.log.levels.INFO, { title = 'SpellCheck' })
    return
  end

  local words_to_add = {}
  for _, diag in ipairs(diagnostics) do
    local word = diag.user_data and diag.user_data.word
    if word then
      words_to_add[word] = true
    end
  end

  local added_count = 0
  for word, _ in pairs(words_to_add) do
    M.update_dictionary(word)
    added_count = added_count + 1
  end

  vim.notify('Added ' .. added_count .. ' unique words to dictionary', vim.log.levels.INFO, { title = 'SpellCheck' })
  M.silent_reset()
end

M.silent_reset = function()
  vim.cmd('silent! spellreload')
  M.debounce_update()
end

M.update_dictionary = function(word)
  vim.fn.mkdir(vim.fn.expand('~/.spell'), 'p')

  local full_dict_path = get_spellfile_path()

  local file = io.open(full_dict_path, 'a')
  if file then
    file:write(word .. '\n')
    file:close()
    vim.notify('Word "' .. word .. '" added to dictionary', vim.log.levels.INFO, { title = 'SpellCheck' })
    M.silent_reset()
  else
    vim.notify(
      'Could not open the dictionary file at ' .. full_dict_path,
      vim.log.levels.ERROR,
      { title = 'SpellCheck' }
    )
  end
end

M.open_dictionary = function()
  vim.cmd('edit ' .. get_spellfile_path())
end

M.fix_word_under_cursor = function()
  if not vim.wo.spell then
    vim.notify('Spell checking must be enabled to fix words', vim.log.levels.WARN, { title = 'SpellCheck' })
    return
  end

  local word = vim.fn.expand('<cword>')
  if word == '' then
    vim.notify('No word under cursor', vim.log.levels.WARN, { title = 'SpellCheck' })
    return
  end

  local corrections = vim.fn.spellsuggest(word)
  if #corrections == 0 then
    vim.notify('No suggestions found for "' .. word .. '"', vim.log.levels.INFO, { title = 'SpellCheck' })
    return
  end

  local best_correction = corrections[1]
  vim.cmd('normal! "_ciw' .. best_correction)

  vim.notify(
    'Replaced "' .. word .. '" with "' .. best_correction .. '"',
    vim.log.levels.INFO,
    { title = 'SpellCheck' }
  )
  M.debounce_update()
end

M.user_commands = function()
  local usercmd = vim.api.nvim_create_user_command

  usercmd('SpellToggle', M.toggle_spell, { desc = 'Enable/Disable spell check' })
  usercmd('SpellShowTelescope', M.telescople_plugin, { desc = 'Show spell errors in telescope' })

  usercmd('SpellAdd', function(opts)
    local word = opts.args
    M.update_dictionary(word)
  end, { nargs = 1, desc = 'Add word to dictionary' })

  usercmd('SpellDiagnostics', function()
    vim.diagnostic.setqflist({ namespace = M.config.ns_id })
  end, { desc = 'Show spell errors in quick fix pane' })
end

M.aucmd = function()
  local autocmd = vim.api.nvim_create_autocmd

  M.config.user_group = vim.api.nvim_create_augroup('SpellDiagnostics', { clear = true })

  autocmd('FileType', {
    group = M.config.user_group,
    pattern = { 'markdown', 'text', 'gitcommit', 'latex', 'typst' },
    callback = function()
      if not vim.wo.spell then
        M.toggle_spell()
      end
    end,
  })

  autocmd({ 'BufEnter', 'BufNewFile' }, {
    group = M.config.user_group,
    callback = function(args)
      autocmd({ 'TextChanged', 'TextChangedI', 'InsertLeave' }, {
        group = M.config.user_group,
        buffer = args.buf,
        callback = M.debounce_update,
        desc = 'Debounce spell diagnostic update',
      })

      if vim.wo.spell then
        vim.schedule(M.update_spell_diagnostics)
      end
    end,
  })
end

M.keymaps = function()
  local map = function(cmd, fun, desc)
    vim.keymap.set('n', '<leader>' .. cmd, fun, { desc = 'Spell check: ' .. desc })
  end

  local smap = function(cmd, fun, desc)
    vim.keymap.set('n', cmd, fun, { desc = 'Spell check: ' .. desc })
  end

  -- Spell keymaps
  map('st', M.toggle_spell, 'Toggle')
  map('sa', M.add_word_to_dictionary_from_cursor, 'Add word from cursor')
  map('sA', M.add_word_to_dictionary_custom, 'Add custom word')
  map('sD', M.add_from_diagnostics, 'Add all diagnostics to dictionary')
  map('so', M.open_dictionary, 'Open dictionary file')
  map('ss', M.show_spell_status, 'Show status')
  map('sT', M.telescople_plugin, 'Show errors in telescope')
  map('sl', function()
    vim.diagnostic.setloclist({ namespace = M.config.ns_id })
  end, 'Show errors in location list')
  map('sq', function()
    vim.diagnostic.setqflist({ namespace = M.config.ns_id })
  end, 'Show errors in quickfix')

  -- ENHANCED KEYMAPS
  smap('zg', M.add_word_to_dictionary_from_cursor, 'Add word from cursor (Vim built-in)')
  smap(']s', function()
    vim.diagnostic.jump({ count = 1, namespace = M.config.ns_id })
  end, 'Go to next spelling error')
  smap('[s', function()
    vim.diagnostic.jump({ count = -1, namespace = M.config.ns_id })
  end, 'Go to previous spelling error')
  map('sf', M.fix_word_under_cursor, 'Fix word under cursor (first suggestion)')
end

M.highlights = function()
  vim.api.nvim_set_hl(0, 'SpellDiagnosticUnderline', {
    undercurl = true,
    sp = '#ff5555',
  })
  vim.api.nvim_set_hl(0, 'DiagnosticUnderlineHint', { link = 'SpellDiagnosticUnderline' })
end

M.diagnostics = function()
  vim.diagnostic.config({
    virtual_text = {
      source = true,
      prefix = '✗ ',
      spacing = 4,
      severity = { min = M.config.diagnostic_severity },
    },
    underline = {
      severity = { min = M.config.diagnostic_severity },
    },
    signs = {
      severity = { min = M.config.diagnostic_severity },
    },
    severity_sort = true,
    update_in_insert = true,
  }, M.config.ns_id)
end

M.telescople_plugin = function()
  local ok, telescope = pcall(require, 'telescope')
  if not ok then
    vim.notify('Telescope is not installed or available', vim.log.levels.ERROR, { title = 'SpellCheck' })
    return
  end

  local ok_ext, diag_ext = pcall(require, 'telescope.extensions.diagnostics')
  if not ok_ext or not diag_ext or type(diag_ext.diagnostic) ~= 'function' then
    vim.notify('Telescope diagnostics extension not loaded', vim.log.levels.ERROR, { title = 'SpellCheck' })
    return
  end

  local buffer = vim.api.nvim_get_current_buf()
  local diagnostics = vim.diagnostic.get(buffer, { namespace = M.config.ns_id })
  if #diagnostics == 0 then
    vim.notify('There are no spelling errors', vim.log.levels.INFO, { title = 'SpellCheck' })
    return
  end

  telescope.extensions.diagnostics.diagnostic({
    namespace = M.config.ns_id,
    bufnr = buffer,
  })
end

M.plugin = function()
  M.user_commands()
  M.highlights()
  M.diagnostics()
  M.aucmd()
  M.keymaps()

  vim.schedule(function()
    M.show_spell_status()
  end)
end

return M
