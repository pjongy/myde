function! s:register() abort
  let l:config = {
    \ 'name': 'Typescript Analysis Server',
    \ 'command': ['typescript-language-server', '--stdio'],
    \}
  call RegisterLanguageServer('typescript', l:config)
endfunction

if !exists('s:initialized')
  call s:register()
  let s:initialized = v:true
endif
