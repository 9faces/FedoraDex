-- Plugins TEZT??

local init
local XInit = game:GetService("UserInputService")
local inputZ = {}
local initualZ = {}

local binds = {}
local connections = {}
local enabled = false

local function getname(object)
    if object.KeyCode ~= Enum.KeyCode.Unknown then
        return string.lower(object.KeyCode.Name)
    end

    return string.lower(object.UserInputType.Name)
end

local function getkey(key)
    if typeof(key) == "EnumItem" then
        return string.lower(key.Name)
    end

    return string.lower(tostring(key))
end

local function getstate(key)
    return inputZ[getkey(key)] == true
end

local function getlast()
    return initualZ.last
end

local function setstate(object, state, processed)
    local key = getname(object)

    inputZ[key] = state

    initualZ.last = key
    initualZ.state = state
    initualZ.processed = processed
    initualZ.time = os.clock()

    return key
end

local function execute(key, object, processed)
    local list = binds[key]

    if not list then
        return
    end

    for _, item in ipairs(list) do
        if not processed or item.processed then
            task.spawn(item.callback, object, processed)
        end
    end
end

local function began(object, processed)
    if not enabled then
        return
    end

    local key = setstate(object, true, processed)

    execute(key, object, processed)
end

local function ended(object, processed)
    if not enabled then
        return
    end

    setstate(object, false, processed)
end

local function bind(key, callback, processed)
    key = getkey(key)

    if type(callback) ~= "function" then
        return
    end

    binds[key] = binds[key] or {}

    local item = {
        callback = callback,
        processed = processed == true
    }

    table.insert(binds[key], item)

    return function()
        local list = binds[key]

        if not list then
            return
        end

        local index = table.find(list, item)

        if index then
            table.remove(list, index)
        end
    end
end

local function unbind(key)
    binds[getkey(key)] = nil
end

local function clear()
    table.clear(inputZ)
    table.clear(initualZ)
end

local function connect()
    if #connections > 0 then
        return
    end

    table.insert(connections, XInit.InputBegan:Connect(began))
    table.insert(connections, XInit.InputEnded:Connect(ended))
end

local function disconnect()
    for _, connection in ipairs(connections) do
        connection:Disconnect()
    end

    table.clear(connections)
end

local function start()
    if enabled then
        return
    end

    enabled = true
    connect()
end

local function stop()
    if not enabled then
        return
    end

    enabled = false
    disconnect()
    clear()
end

init = function()
    start()

    return {
        bind = bind,
        unbind = unbind,
        get = getstate,
        last = getlast,
        clear = clear,
        start = start,
        stop = stop
    }
end

return init()
