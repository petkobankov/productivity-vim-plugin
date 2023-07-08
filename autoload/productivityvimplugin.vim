let g:tasks = {}
let g:priority_task = ''
let g:current_task = ''
let g:can_have_break = 0
let g:timer_running = 0
let g:pomodoro_timer = 25
let g:break_timer = 5
let g:current_status = 'no_timer'

function! productivityvimplugin#AddTaskWithPomodoros(task, pomodoros)
    call productivityvimplugin#LoadTasksFromFile()
    if len(g:tasks) >= 3
        echo 'No more than 3 tasks for today.'
        return
    endif
    let g:tasks[a:task] = a:pomodoros
    call productivityvimplugin#SaveTasksToFile()
    call productivityvimplugin#SeeTasks()
    echo 'Task added: ' . a:task . ' - ' . a:pomodoros
endfunction

function! productivityvimplugin#ToggleTasks()
    call productivityvimplugin#LoadTasksFromFile()
    if bufwinnr('Tasks for today') > 0
        bdelete 'Tasks for today'
    else
        call productivityvimplugin#SeeTasks()
    endif
endfunction

function! productivityvimplugin#SeeTasks()
    call productivityvimplugin#LoadTasksFromFile()
    if bufwinnr('Tasks for today') > 0
        bdelete 'Tasks for today'
    endif
    new 'Tasks for today'
    nnoremap <buffer> <CR> :call productivityvimplugin#SelectTask()<CR>
    setlocal buftype=nofile
    setlocal nonumber
    call setline(1, keys(g:tasks))
endfunction

function! productivityvimplugin#SetAsPriority()
    let g:priority_task = getline('.')
endfunction

function! productivityvimplugin#SelectTask()
    let g:current_task = getline('.')
    echo 'Selected task: ' . g:current_task .' with pomodoros left: ' . g:tasks[g:current_task]
endfunction

function! productivityvimplugin#CompleteTask()
    call remove(g:tasks, g:current_task)
    call productivityvimplugin#SaveTasksToFile()
    echo 'Task completed: ' . g:current_task
    let g:current_task = ''
    call productivityvimplugin#SeeTasks()
    
endfunction

function! productivityvimplugin#SaveTasksToFile()
    let file = expand('~/.vimtasks')
    call writefile(json_encode(g:tasks)->split(), file)
endfunction

function! productivityvimplugin#LoadTasksFromFile()
    let file = expand('~/.vimtasks')
    if filereadable(file)
        let g:tasks = json_decode(readfile(file)->join())
    else
        call productivityvimplugin#SaveTasksToFile()
    endif
endfunction

function! productivityvimplugin#StartPomodoro()
    if g:timer_running
        echo 'A timer is already running.'
        return
    endif
    let g:timer_running = 1
    let g:timer_status = 'pomodoro'
    call productivityvimplugin#UpdateStatusBar()
    echo 'Started pomodoro for task: '. g:current_task . ' with pomodoros: '. g:tasks[g:current_task]
    call timer_start(g:pomodoro_timer * 60 * 1000, function('productivityvimplugin#PomodoroFinished'))
endfunction

function! productivityvimplugin#PomodoroFinished(arg)
    let g:tasks[g:current_task] -= 1
    call productivityvimplugin#SaveTasksToFile()
    let g:timer_running = 0
    let g:can_have_break = 1
    let g:timer_status = 'no_timer'
    call productivityvimplugin#UpdateStatusBar()
    echo 'Pomodoro is done! Pomodoros left for task '. g:current_task .': ' . g:tasks[g:current_task]
endfunction

function! productivityvimplugin#StartBreak()
    if g:timer_running
        echo 'A timer is already running.'
        return
    endif
    if !g:can_have_break
        echo 'Break timer not allowed at the moment.'
        return
    endif
    let g:timer_running = 1
    let g:timer_status = 'break'
    call productivityvimplugin#UpdateStatusBar()
    echo 'Started break'
    call timer_start(g:break_timer * 60 * 1000, function('productivityvimplugin#BreakFinished'))
endfunction

function! productivityvimplugin#BreakFinished(arg)
    let g:timer_running = 0
    let g:can_have_break = 0
    let g:timer_status = 'no_timer'
    call productivityvimplugin#UpdateStatusBar()
    echo 'Break is done!'
endfunction

function! productivityvimplugin#UpdateStatusBar()
    let &statusline = '|%F| Timer status: '
    if g:timer_status == 'pomodoro'
        let &statusline .= 'Pomodoro Timer'
    elseif g:timer_status == 'break'
        let &statusline .= 'Break Timer'
    else
        let &statusline .= 'No Timer'
    endif
endfunction