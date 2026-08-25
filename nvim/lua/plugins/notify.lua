local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/rcarriga/nvim-notify' },
  })

  if not Checker.check('notify') then
    return
  end

  local notify = require('notify')

  local opts = {
    background_colour = '#000000', -- Ideal para que se funda bien con Tokyonight
    stages = 'fade', -- Animación de desvanecimiento
    timeout = 3000, -- Los mensajes desaparecerán en 3 segundos
    max_width = 50,
  }

  notify.setup(opts)

  -- ¡LA MAGIA! Le decimos a Neovim que reemplace sus mensajes aburridos
  -- por este nuevo sistema de ventanas flotantes.
  vim.notify = notify
end

return M
