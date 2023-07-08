if exists('g:loaded_productivity-vim-plugin') || &cp
  finish
endif

let g:loaded_productivity-vim-plugin = '0.0.1' " version number
let s:keepcpo = &cpo
set cpo&vim



let &cpo = s:keepcpo
unlet s:keepcpo
