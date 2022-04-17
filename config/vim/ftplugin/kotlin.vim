function! s:register() abort
  let l:config = {
    \ 'name': 'Kotlin Analysis Server',
    \ 'command': ['kotlin-language-server'],
    \}
  call RegisterLanguageServer('kotlin', l:config)
endfunction

if !exists('s:initialized')
  call s:register()
  let s:initialized = v:true
endif
