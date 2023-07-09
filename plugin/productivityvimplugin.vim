if exists('g:loaded_productivity_vim_plugin') || &cp
  finish
endif

let g:loaded_productivity_vim_plugin = '0.0.1' " version number
if !exists('g:pomodoro_timer')
  let g:pomodoro_timer = 25
endif
if !exists('g:break_timer')
  let g:break_timer = 5
endif
let s:keepcpo = &cpo

set cpo&vim

command! -nargs=* AddTask call productivityvimplugin#AddTaskWithPomodoros(<f-args>)
command! -nargs=0 SeeTasks call productivityvimplugin#ToggleTasks()
command! -nargs=0 SetAsPriority call productivityvimplugin#SetAsPriority()
command! -nargs=0 SelectTask call productivityvimplugin#SelectTask()
command! -nargs=0 StartPomodoro call productivityvimplugin#StartPomodoro()
command! -nargs=0 StartBreak call productivityvimplugin#StartBreak()
command! -nargs=0 CompleteTask call productivityvimplugin#CompleteTask()

nnoremap gb :SeeTasks<cr>

let &cpo = s:keepcpo
unlet s:keepcpo
