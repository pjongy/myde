function! s:register() abort
  let l:config = {
    \ 'name': 'Javascript Analysis Server',
    \ 'command': ['typescript-language-server', '--stdio'],
    \}
  call RegisterLanguageServer('javascript', l:config)
endfunction

if !exists('s:initialized')
  call s:register()
  let s:initialized = v:true
endif
