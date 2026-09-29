local M = {}

local function setup()
  vim.filetype.add({
    extension = {
      ini = 'dosini',
      cfg = 'dosini',
      tofu = 'opentofy',
    },

    filename = {
      -- Ollama
      ['Modelfile'] = 'modelfile',
      ['modelfile'] = 'modelfile',

      -- podman / docker
      ['Containerfile'] = 'dockerfile',
      ['containerfile'] = 'dockerfile',

      -- Nginx
      ['nginx.conf'] = 'nginx',
    },

    pattern = {
      -- ollama
      ['.*[Mm]odelfile%..*'] = 'modelfile',

      -- podman
      ['.*[Cc]ontainerfile%..*'] = 'dockerfile',

      -- nginx
      ['.*/nginx/.*%.conf'] = 'nginx',
      ['.*/nginx/conf%.d/.*%.conf'] = 'nginx',
      ['.*/nginx/sites%-available/.*'] = 'nginx,',
      ['.*/nginx/sites%-enabled/.*'] = 'nginx,',

      -- tmux
      ['.*/tmux/.*%.conf'] = 'tmux',

      -- hyprland
      ['.*/hypr/.*%.conf'] = 'hyprlang',

      -- ini-like configs
      ['.*/btop/.*%.conf'] = 'dosini',
      ['.*/weechat/.*%.conf'] = 'dosini',
      ['.*/nchat/.*%.conf'] = 'dosini',

      -- neofetch is bash
      ['.*/neofetch/.*%.conf'] = 'bash',
    },
  })

  local reg = vim.treesitter.language.register

  reg('dockerfile', 'modelfile')
  reg('ini', 'dosini')
  reg('bash', 'sh')
  reg('terraform', {
    'terraform-vars',
    'opentofu',
    'opentofu-vars',
  })
  reg('yaml', {
    'yaml.github',
    'yaml.gitlab',
    'yaml.helm-values',
    'taml.docker-compose',
  })
end

M.setup = setup

return M
