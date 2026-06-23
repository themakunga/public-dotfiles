local M = {}

M.plugin = function()
  vim.pack.add({
    { src = 'https://github.com/nvim-lualine/lualine.nvim', },
  })

--@module 'lualine'
local ok, lualine = pcall(require, 'lualine')

if not ok then
  vim.notify("[CHECK REQUIRE FAILED] lualine "..debug.getinfo(2).source, vim.log.levels.WARN)
  return
end

local colors = {
        blue = "#65D1FF",
        green = "#3EFFDC",
        violet = "#FF61EF",
        yellow = "#FFDA7B",
        red = "#FF4A4A",
        fg = "#c3ccdc",
        bg = "#112638",
        inactive_bg = "#2c3043",
    }

local my_lualine_theme = {
        normal = {
            a = { bg = colors.blue, fg = colors.bg, gui = "bold" },
            b = { bg = colors.bg, fg = colors.fg },
            c = { bg = colors.bg, fg = colors.fg },
        },
        insert = {
            a = { bg = colors.green, fg = colors.bg, gui = "bold" },
            b = { bg = colors.bg, fg = colors.fg },
            c = { bg = colors.bg, fg = colors.fg },
        },
        visual = {
            a = { bg = colors.violet, fg = colors.bg, gui = "bold" },
            b = { bg = colors.bg, fg = colors.fg },
            c = { bg = colors.bg, fg = colors.fg },
        },
        command = {
            a = { bg = colors.yellow, fg = colors.bg, gui = "bold" },
            b = { bg = colors.bg, fg = colors.fg },
            c = { bg = colors.bg, fg = colors.fg },
        },
        replace = {
            a = { bg = colors.red, fg = colors.bg, gui = "bold" },
            b = { bg = colors.bg, fg = colors.fg },
            c = { bg = colors.bg, fg = colors.fg },
        },
        inactive = {
            a = { bg = colors.inactive_bg, fg = colors.semilightgray, gui = "bold" },
            b = { bg = colors.inactive_bg, fg = colors.semilightgray },
            c = { bg = colors.inactive_bg, fg = colors.semilightgray },
        },
    }



--@type lualine.SetupOps
local opts = {
  options = {
            theme = my_lualine_theme,
        },
        sections = {
            lualine_x = {
                { "encoding" },
                { "fileformat" },
                { "filetype" },
            },
        },

}

lualine.setup(opts)


-- vim.keymap.set('n', '<leader>ee', '<cmd>lualine<cr>', {desc = "Open parent directory"})
end

return M
