function! s:register() abort
  let l:config = {
    \ 'name': 'Python Analysis Server',
    \ 'command': ['PYTHON_PATH', '-m', 'pylsp'],
    \}
  call RegisterLanguageServer('python', l:config)
endfunction

if !exists('s:initialized')
  call s:register()
  let s:initialized = v:true
endif
