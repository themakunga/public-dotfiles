" Ollama directives and triple-quoted prompts have their own syntax.
if exists('b:current_syntax')
  finish
endif

syntax case ignore
syntax match modelfileComment /^\s*#.*/ contains=@Spell
syntax match modelfileInstruction /^\s*\zs\%(FROM\|TEMPLATE\|SYSTEM\|ADAPTER\|LICENSE\|REQUIRES\)\>/
syntax match modelfileInstruction /^\s*\zsPARAMETER\>/ nextgroup=modelfileParameter skipwhite
syntax match modelfileInstruction /^\s*\zsMESSAGE\>/ nextgroup=modelfileRole skipwhite
syntax match modelfileParameter /\S\+/ contained
syntax keyword modelfileRole system user assistant contained
syntax region modelfileString start=/"/ skip=/\\./ end=/"/ oneline contains=@Spell
syntax region modelfileMultiline start=/"""/ end=/"""/ contains=modelfileTemplate,@Spell
syntax region modelfileTemplate start=/{{/ end=/}}/ contained
syntax sync fromstart

highlight default link modelfileComment Comment
highlight default link modelfileInstruction Keyword
highlight default link modelfileParameter Identifier
highlight default link modelfileRole Type
highlight default link modelfileString String
highlight default link modelfileMultiline String
highlight default link modelfileTemplate Special
let b:current_syntax = 'modelfile'
