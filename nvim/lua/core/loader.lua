local M = {}

local function do_load(module_name)
  local ok, mod = pcall(require, module_name)

  if not ok then
    Log.error('No se pudo cargar: ' .. module_name .. '\n' .. tostring(mod), 'Loader Crash')
    return
  end

  if type(mod) ~= 'table' then
    return
  end

  local lifecycle_methods = { 'init', 'load', 'plugin' }

  for _, method in ipairs(lifecycle_methods) do
    if type(mod[method]) == 'function' then
      local success, err = pcall(mod[method])

      if not success then
        Log.error(string.format('Error en [%s] -> %s()\nDetalle: %s', module_name, method, err), 'Module Crash')
      end
    end
  end
end

M.load = do_load

-- Metatabla para poder usar Loader('modulo')
setmetatable(M, {
  __call = function(_, module_name)
    do_load(module_name)
  end,
})

return M
