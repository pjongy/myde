function! s:register() abort
  let l:config = {
    \ 'name': 'Svelte Analysis Server',
    \ 'command': ['svelteserver', '--stdio'],
    \}
  call RegisterLanguageServer('svelte', l:config)
endfunction

if !exists('s:initialized')
  call s:register()
  let s:initialized = v:true
endif
