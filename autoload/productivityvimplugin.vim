let g:tasks = {}

function! productivityvimplugin#AddTaskWithPomodoros(task, pomodoros)
    call productivityvimplugin#LoadTasksFromFile()
    if len(g:tasks) >= 3
        echo 'No more than 3 tasks for today.'
        return
    endif
    let g:tasks[a:task] = a:pomodoros
    call productivityvimplugin#SaveTasksToFile()
    echo 'Task added: ' . a:task . ' - ' . a:pomodoros
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
