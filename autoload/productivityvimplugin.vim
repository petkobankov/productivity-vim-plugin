let s:tasks = {}
let s:priority_task = ''
let s:current_task = ''
let s:can_have_break = 0
let s:timer_running = 0
let s:current_status = 'no_timer'
let s:minute_to_milisecond = 60 * 1000

function! productivityvimplugin#AddTaskWithPomodoros(task, pomodoros)
    call productivityvimplugin#LoadTasksFromFile()
    if len(s:tasks) >= 3
        echo 'No more than 3 tasks for today.'
        return
    endif
    let s:tasks[a:task] = a:pomodoros
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
    call setline(1, keys(s:tasks))
endfunction

function! productivityvimplugin#SetAsPriority()
    let s:priority_task = getline('.')
endfunction

function! productivityvimplugin#SelectTask()
    let s:current_task = getline('.')
    echo 'Selected task: ' . s:current_task .' with pomodoros left: ' . s:tasks[s:current_task]
endfunction

function! productivityvimplugin#CompleteTask()
    call remove(s:tasks, s:current_task)
    call productivityvimplugin#SaveTasksToFile()
    echo 'Task completed: ' . s:current_task
    let s:current_task = ''
    call productivityvimplugin#SeeTasks()
    
endfunction

function! productivityvimplugin#SaveTasksToFile()
    let file = expand('~/.vimtasks')
    call writefile(json_encode(s:tasks)->split(), file)
endfunction

function! productivityvimplugin#LoadTasksFromFile()
    let file = expand('~/.vimtasks')
    if filereadable(file)
        let s:tasks = json_decode(readfile(file)->join())
    else
        call productivityvimplugin#SaveTasksToFile()
    endif
endfunction

function! productivityvimplugin#StartPomodoro()
    if s:timer_running
        echo 'A timer is already running.'
        return
    endif
    let s:timer_running = 1
    let s:timer_status = 'pomodoro'
    call productivityvimplugin#UpdateStatusBar()
    echo 'Started pomodoro for task: '. s:current_task . ' with pomodoros: '. s:tasks[s:current_task]
    call timer_start(g:pomodoro_timer * s:minute_to_milisecond, function('productivityvimplugin#PomodoroFinished'))
endfunction

function! productivityvimplugin#PomodoroFinished(arg)
    let s:tasks[s:current_task] -= 1
    call productivityvimplugin#SaveTasksToFile()
    let s:timer_running = 0
    let s:can_have_break = 1
    let s:timer_status = 'no_timer'
    call productivityvimplugin#UpdateStatusBar()
    echo 'Pomodoro is done! Pomodoros left for task '. s:current_task .': ' . s:tasks[s:current_task]
endfunction

function! productivityvimplugin#StartBreak()
    if s:timer_running
        echo 'A timer is already running.'
        return
    endif
    if !s:can_have_break
        echo 'Break timer not allowed at the moment.'
        return
    endif
    let s:timer_running = 1
    let s:timer_status = 'break'
    call productivityvimplugin#UpdateStatusBar()
    echo 'Started break'
    call timer_start(g:break_timer * s:minute_to_milisecond, function('productivityvimplugin#BreakFinished'))
endfunction

function! productivityvimplugin#BreakFinished(arg)
    let s:timer_running = 0
    let s:can_have_break = 0
    let s:timer_status = 'no_timer'
    call productivityvimplugin#UpdateStatusBar()
    echo 'Break is done!'
endfunction

function! productivityvimplugin#UpdateStatusBar()
    let &statusline = '|%F| Timer status: '
    if s:timer_status == 'pomodoro'
        let &statusline .= 'Pomodoro Timer'
    elseif s:timer_status == 'break'
        let &statusline .= 'Break Timer'
    else
        let &statusline .= 'No Timer'
    endif
endfunction