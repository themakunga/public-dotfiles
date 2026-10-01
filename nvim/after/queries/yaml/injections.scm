; extends

; Argo script.source and container/script args. Resolve command in any key order.
((block_mapping_pair
  key: (flow_node) @_key
  value: (block_node
    (block_scalar) @injection.content))
  (#eq? @_key "source")
  (#argo-language! @injection.content))

((block_mapping_pair
  key: (flow_node) @_key
  value: (block_node
    (block_sequence
      (block_sequence_item
        (block_node
          (block_scalar) @injection.content)))))
  (#eq? @_key "args")
  (#argo-language! @injection.content))
