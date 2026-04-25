local save = {}

local SAVE_FILE = "savegame.lua"
local writer = nil

local function escapeString(str)
    str = tostring(str)
    str = str:gsub("\\", "\\\\")
    str = str:gsub("\"", "\\\"")
    str = str:gsub("\n", "\\n")
    str = str:gsub("\r", "\\r")
    str = str:gsub("\t", "\\t")
    return "\"" .. str .. "\""
end

local function isArray(tbl)
    local count = 0
    local maxIndex = 0
    for key in pairs(tbl) do
        if type(key) ~= "number" then
            return false
        end
        if key > maxIndex then
            maxIndex = key
        end
        count = count + 1
    end
    return maxIndex == count
end

local function serializeValue(value, indent, visited)
    local valueType = type(value)
    if valueType == "string" then
        return escapeString(value)
    elseif valueType == "number" or valueType == "boolean" or valueType == "nil" then
        return tostring(value)
    elseif valueType == "table" then
        if visited[value] then
            return "nil"
        end
        visited[value] = true

        local parts = {}
        local indentNext = indent .. "    "
        local isArr = isArray(value)

        if next(value) == nil then
            return "{}"
        end

        if isArr then
            for i = 1, #value do
                table.insert(parts, serializeValue(value[i], indentNext, visited))
            end
            return "{ " .. table.concat(parts, ", ") .. " }"
        end

        for key, item in pairs(value) do
            local formattedKey
            if type(key) == "string" and key:match("^[%a_][%w_]*$") then
                formattedKey = key
            else
                formattedKey = "[" .. serializeValue(key, indentNext, visited) .. "]"
            end
            table.insert(parts, formattedKey .. " = " .. serializeValue(item, indentNext, visited))
        end

        return "{ " .. table.concat(parts, ", ") .. " }"
    else
        return "nil"
    end
end

function save.registerWriter(fn)
    writer = fn
end

function save.saveState(data)
    if not data then
        return false
    end

    local contents = "return " .. serializeValue(data, "", {})
    love.filesystem.write(SAVE_FILE, contents)
    return true
end

function save.save()
    if writer then
        local data = writer()
        return save.saveState(data)
    end
    return false
end

function save.delete()
    if love.filesystem.getInfo(SAVE_FILE) then
        love.filesystem.remove(SAVE_FILE)
        return true
    end
    return false
end

function save.load()
    if not love.filesystem.getInfo(SAVE_FILE) then
        return nil
    end

    local contents = love.filesystem.read(SAVE_FILE)
    if not contents then
        return nil
    end

    local chunk, err = load(contents)
    if not chunk then
        print("Save load error: " .. tostring(err))
        return nil
    end

    local ok, data = pcall(chunk)
    if not ok then
        print("Save load error: " .. tostring(data))
        return nil
    end

    return data
end

return save
