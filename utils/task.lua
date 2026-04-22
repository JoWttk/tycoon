local task = {}

task.threads = {}

function task.spawn(func)
    local co = coroutine.create(func)

    local success, err = coroutine.resume(co)
    if not success then
        print("coroutine error :( ", err)
        return
    end

    table.insert(task.threads, co)
end

function task.update(dt)
    for i = #task.threads, 1, -1 do
        local co = task.threads[i]

        if coroutine.status(co) == "dead" then
            table.remove(task.threads, i)
        else
            local success, err = coroutine.resume(co, dt)

            if not success then
                print("coroutine error :( ", err)
                table.remove(task.threads, i)
            end
        end
    end
end

function task.wait(seconds)
    local timer = 0

    while timer < seconds do
        local dt = coroutine.yield()
        timer = timer + (dt or 0)
    end
end

return task