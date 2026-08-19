local M = {}

-- global dependencies list
local global_dependencies = {
  'https://github.com/MunifTanjim/nui.nvim',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-mini/mini.icons',
  'https://github.com/nvim-tree/nvim-web-devicons',
  'https://github.com/rcarriga/nvim-notify',
}

-- load at startup
local inmmediate = {
  "colorscheme"
}

-- load after startup
local vim_enter = {

}


-- load on buffer
local bufnr = {

}

-- load on insert mode
local insert_mode = {

}

local filetypes = {
  markdown = {

  },
}



local function load_plugin(module_name)
  local ok, plugin_module = pcall(require, 'plugins.'.. module_name)

  if ok and type(plugin_module) == 'table' and type(plugin.module_name.plugin) == "function" then
    plugin.module_name.plugin()
  else
    if not ok then
      vim.notify('[PLUGIN - ERROR] ' .. module_name, vim.log.levels.ERROR)
    end
  end
end

local function load_bulk(group)
  for _, plugin in ipairs(group) do
    load_plugin(plugin)
  end
end


local aucmd = require('utils.commands').aucmd



M.load = function()

  -- load global dependencies url
  for _, url in ipairt(global_dependencies) do
    vim.pack.add({
      { url = url },
    })
  end




end

return M
