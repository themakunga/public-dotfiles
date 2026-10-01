local M = {}

local languages = {
  python = 'python',
  python2 = 'python',
  python3 = 'python',
  java = 'java',
  jshell = 'java',
  sh = 'bash',
  bash = 'bash',
  dash = 'bash',
  ash = 'bash',
  zsh = 'zsh',
  lua = 'lua',
  luajit = 'lua',
  go = 'go',
  node = 'javascript',
  nodejs = 'javascript',
  javascript = 'javascript',
}

local function text(node, source)
  return vim.treesitter.get_node_text(node, source):gsub('^["\']', ''):gsub('["\']$', '')
end

function M.setup()
  vim.treesitter.query.add_directive('argo-language!', function(match, _, source, predicate, metadata)
    local id = predicate[2]
    local content = match[id][1]
    if vim.treesitter.get_node_text(content, source):sub(1, 1) ~= '|' then
      return
    end
    local mapping = content:parent()
    while mapping and mapping:type() ~= 'block_mapping' do
      mapping = mapping:parent()
    end
    local owner = mapping and mapping:parent():parent()
    if not owner or owner:type() ~= 'block_mapping_pair' then
      return
    end
    local key = text(owner:field('key')[1], source)
    if key ~= 'script' and key ~= 'container' then
      return
    end

    for pair in mapping:iter_children() do
      if pair:type() == 'block_mapping_pair' and text(pair:field('key')[1], source) == 'command' then
        local value = pair:field('value')[1]
        local sequence = value and value:named_child(0)
        if not sequence or (sequence:type() ~= 'flow_sequence' and sequence:type() ~= 'block_sequence') then
          return
        end
        local command = sequence:named_child(0)
        if not command then
          return
        end
        if command:type() == 'block_sequence_item' then
          command = command:named_child(0)
        end
        if not command then
          return
        end
        -- ponytail: infer only direct commands; add wrapper handling when needed.
        local executable = text(command, source):match('[^/]+$') or ''
        local language = languages[executable]
          or (executable:match('^python%d+%.%d+$') and 'python')
          or (executable:match('^lua%d+%.%d+$') and 'lua')
        if language then
          metadata['injection.language'] = language
          local sr, _, er, ec = content:range()
          metadata[id] = { range = { sr + 1, 0, er, ec } }
        end
        return
      end
    end
  end, { force = true })
end

return M
