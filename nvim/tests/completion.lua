-- Run: nvim --headless -u NONE -i NONE -l tests/completion.lua
vim.opt.runtimepath:prepend(vim.fn.getcwd())
vim.opt.virtualedit = 'onemore'

local pending, result, popup
local now = 1730678400
local real_time = os.time
os.time = function()
  return now
end
vim.defer_fn = function(callback)
  pending = callback
  return {
    stop = function()
      pending = nil
    end,
  }
end
vim.fn.pumvisible = function()
  return popup and 1 or 0
end
vim.fn.complete = function(start_col, items)
  result = { start_col = start_col, items = items }
end
require('plugins.completion').init()

local function complete(prefix)
  pending, result = nil, nil
  local line = 'note ' .. prefix
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { line })
  vim.api.nvim_win_set_cursor(0, { 1, #line })
  vim.api.nvim_exec_autocmds('TextChangedI', {})
  if pending then
    pending()
  end
  return result and result.items or {}
end

for trigger, expected in pairs({
  date = os.date('%Y-%m-%d', now),
  time = os.date('%H:%M:%S', now),
  datetime = os.date('%Y-%m-%dT%H:%M:%S%z', now),
  timestamp = tostring(now),
}) do
  local items = complete(trigger)
  assert(items[1].word == expected, trigger)
  assert(items[1].abbr == trigger .. ' → ' .. expected, trigger)
  assert(items[1].equal == 1, 'Generated values must bypass prefix filtering')
  assert(result.start_col == 6, 'Replace only the trigger')
end

assert(#complete('da') == 2, 'Suggest both date and datetime')
assert(complete('TIME')[1].word == os.date('%H:%M:%S', now), 'Ignore trigger case')
now = now + 60
assert(complete('timestamp')[1].word == tostring(now), 'Refresh values on every request')
assert(#complete('d') == 0, 'Do not suggest on a single character')
assert(#complete('updatedate') == 0, 'Match whole word prefixes only')
assert(#complete('./date') == 0, 'Preserve path completion')
assert(complete('no')[1].word == 'note', 'Preserve buffer completion')
popup = true
assert(#complete('date') == 0, 'Preserve existing popup priority')
os.time = real_time
print('Native date/time completion: OK')
