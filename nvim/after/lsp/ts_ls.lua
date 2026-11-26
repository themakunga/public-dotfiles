---@type vim.lsp.Config
return {
  -- Vue's hybrid server needs tsserver; keep TypeScript 7 for other filetypes.
  filetypes = { 'vue' },
  init_options = {
    plugins = {
      {
        name = '@vue/typescript-plugin',
        location = vim.fn.stdpath('data') .. '/mason/packages/vue-language-server/node_modules/@vue/language-server',
        languages = { 'vue' },
        configNamespace = 'typescript',
      },
    },
  },
}
