-- Run from nvim/ with Mason's Vue and TypeScript servers installed:
-- nvim --headless -u NONE -i NONE -l tests/vue.lua
vim.cmd.packadd('nvim-lspconfig')
vim.opt.runtimepath:prepend(vim.fn.getcwd())
vim.opt.runtimepath:append(vim.fn.getcwd() .. '/after')
vim.env.PATH = vim.fn.stdpath('data') .. '/mason/bin:' .. vim.env.PATH
local root = vim.fn.tempname()
vim.fn.mkdir(root, 'p')
vim.fn.writefile({ '{}' }, root .. '/package.json')
vim.fn.writefile({ '{"compilerOptions":{"strict":true},"include":["*.vue"]}' }, root .. '/tsconfig.json')
vim.fn.writefile({
  '<script setup lang="ts">',
  'const count: number = "wrong"',
  '</script>',
  '<template>{{ count }}</template>',
}, root .. '/App.vue')
local errors = {}
local notify = vim.notify
vim.notify = function(message, level)
  if level == vim.log.levels.ERROR then
    table.insert(errors, message)
  end
end
vim.lsp.enable({ 'tsc', 'ts_ls', 'vue_ls' })
vim.cmd.edit(root .. '/App.vue')
vim.bo.filetype = 'vue'
local checked = vim.wait(10000, function()
  return #errors > 0
    or vim.iter(vim.diagnostic.get(0)):any(function(diagnostic)
      return diagnostic.code == 2322
    end)
end)
local clients = vim.tbl_map(function(client)
  return client.name
end, vim.lsp.get_clients({ bufnr = 0 }))
for _, client in ipairs(vim.lsp.get_clients()) do
  client:stop(true)
end
vim.notify = notify
vim.cmd('bwipeout!')
vim.fn.delete(root, 'rf')
assert(#errors == 0, table.concat(errors, '\n'))
assert(checked, 'Vue script did not receive TypeScript diagnostics')
assert(vim.tbl_contains(clients, 'vue_ls') and vim.tbl_contains(clients, 'ts_ls'), vim.inspect(clients))
assert(not vim.tbl_contains(clients, 'tsc'), 'TypeScript 7 must not handle Vue buffers')
assert(vim.deep_equal(vim.lsp.config.ts_ls.filetypes, { 'vue' }), 'Keep TypeScript 7 for ordinary TS/JS files')
print('Vue hybrid connection and real TypeScript diagnostics: OK')
