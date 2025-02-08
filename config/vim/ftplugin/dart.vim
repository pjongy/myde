function! s:register() abort
  let l:config = {
    \ 'name': 'Dart Analysis Server',
    \ 'command': ['dart', '/opt/dart/dart-sdk/bin/snapshots/analysis_server.dart.snapshot', '--lsp', '--client-id', 'vim'],
    \ 'message_hooks': {
    \   'initialize': {
    \     'initializationOptions': {
    \       'onlyAnalyzeProjectsWithOpenFiles': v:true
    \     }
    \   },
    \ },
    \}
  call RegisterLanguageServer('dart', l:config)
endfunction

if !exists('s:initialized')
  call s:register()
  let s:initialized = v:true
endif
