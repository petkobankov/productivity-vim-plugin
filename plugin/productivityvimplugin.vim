if exists('g:loaded_productivity_vim_plugin') || &cp
  finish
endif

let g:loaded_productivity_vim_plugin = '0.0.1' " version number
let s:keepcpo = &cpo
set cpo&vim

command! -nargs=* AddTask call productivityvimplugin#AddTaskWithPomodoros(<f-args>)

let &cpo = s:keepcpo
unlet s:keepcpo
