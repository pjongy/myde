function! s:register() abort
  let l:config = {
    \ 'name': 'Rust Analysis Server',
    \ 'command': ['rust-analyzer'],
    \}
  call RegisterLanguageServer('rust', l:config)
endfunction

if !exists('s:initialized')
  call s:register()
  let s:initialized = v:true
endif
