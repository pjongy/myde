function! s:register() abort
  let l:config = {
    \ 'name': 'Go Analysis Server',
    \ 'command': ['gopls'],
    \}
  call RegisterLanguageServer('go', l:config)
endfunction

if !exists('s:initialized')
  call s:register()
  let s:initialized = v:true
endif
