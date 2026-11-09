; extends

((task
  (priority) @comment.error)
  (#eq? @comment.error "(A)")
  (#set! priority 110))

((task
  (priority) @comment.warning)
  (#eq? @comment.warning "(B)")
  (#set! priority 110))

((task
  (priority) @comment.note)
  (#eq? @comment.note "(C)")
  (#set! priority 110))

((done_task) @markup.strikethrough
  (#set! priority 110))
