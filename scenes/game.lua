local machine = require("modules.machine")
local task = require("utils.task")
local user = require("user")
local button = require("modules.ui.button")
local shop = require("windows.shop")
local save = require("save")

local game = {}
game.editing = false
game.isEditing = nil
game.isEditingRunning = nil

local OutroTeste

function game_edit(machine)
    game.editing = true
    game.isEditing = machine
    game.isEditingRunning = machine.running
end

function exit_edit()
    game.editing = false

    game.isEditing:setColor(game.isEditing.baseColor[1], game.isEditing.baseColor[2], game.isEditing.baseColor[3])
    game.isEditing:setRunning(game.isEditingRunning)

    game.isEditing = nil
end

local function buildSaveData()
    local data = user.getSaveData()
    data.ownedMachines = data.machines
    data.machines = {}

    for _, m in ipairs(machine.list) do
        table.insert(data.machines, {
            kind = m.kind,
            name = m.name,
            posX = m.posX,
            posY = m.posY,
            sizeX = m.sizeX,
            sizeY = m.sizeY,
            speed = m.speed,
            running = m.running,
            floor = m.floor,
            color = m.color,
            baseColor = m.baseColor,
        })
    end

    return data
end

local function restoreSavedMachines(savedMachines)
    if type(savedMachines) ~= "table" then
        return
    end

    for _, machineState in ipairs(savedMachines) do
        local kind = machineState.kind or "default"
        local ok, machineModule = pcall(require, "machines." .. kind)
        if ok and machineModule and machineModule.load then
            machineModule.load(machineState)
        end
    end
end

function game.load()
    love.graphics.setBackgroundColor(0.3, 0.3, 0.3)
    machine.list = {}

    user.load()
    save.registerWriter(buildSaveData)

    local saveData = save.load()
    if saveData then
        user.restoreFromSave(saveData)
        restoreSavedMachines(saveData.machines)
    else
        local defaultMachine = require("machines.default")
        defaultMachine.load()
    end

    if not saveData or not saveData.machines or #saveData.machines == 0 then
        local defaultMachine = require("machines.default")
        if #machine.list == 0 then
            defaultMachine.load()
        end
    end

    user.onFloorChange = function(floorNum)
        if game.editing and game.isEditing then
            game.isEditing.floor = floorNum
        end
    end

    save.save()
end

function game.update(dt)
    local mx, my = love.mouse.getPosition()
    machine.updateAllHover(mx, my, user.floor)
    user.update(dt)

    if game.editing and game.isEditing then
        if love.keyboard.isDown("d") then
            game.isEditing:move(200 * dt, 0)
        elseif love.keyboard.isDown("a") then
            game.isEditing:move(-200 * dt, 0)
        elseif love.keyboard.isDown("w") then
            game.isEditing:move(0, -200 * dt)
        elseif love.keyboard.isDown("s") then
            game.isEditing:move(0, 200 * dt)
        end
    end

    local hoveredMachine = machine.getHovered(user.floor)
    local hoveredButton = button.getHovered()

    if hoveredMachine or hoveredButton then
        love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
    else
        love.mouse.setCursor()
    end
end

function game.draw()
    machine.drawAll(user.floor)
    user.draw()
    
    local w, h = love.graphics.getDimensions()
    love.graphics.setColor(0.1,0.1,0.1)

    love.graphics.setLineWidth(4)
    love.graphics.rectangle("line", 0, 0, w, h - 680)
    love.graphics.rectangle("line", 0, 0, w, h - 60)
    love.graphics.rectangle("line", 138,660, 0.1, 60)

    love.graphics.setLineWidth(12)
    love.graphics.rectangle("line", 0, 0, w, h)
    
    love.graphics.setLineWidth(1)
    
    local mx, my = love.mouse.getPosition()
    local hovered = machine.getHovered()

    if game.editing and game.isEditing then
        love.graphics.setColor(1, 0.5, 0.5)
        love.graphics.setFont(fonts.small)

        local text = "Editing: " .. game.isEditing.name .. " - Use WASD to move | ESC to exit"
        local textWidth = love.graphics.getFont():getWidth(text)

        game.isEditing:setColor(1, 0.5, 0.5)
        game.isEditing:setRunning(false)

        love.graphics.print(text, w/2 - textWidth/2, 15)
        love.graphics.setFont(fonts.default)
    end

    if hovered then
        love.graphics.setColor(1, 1, 1)

        love.graphics.setFont(fonts.small)
        local text = "Hovering over: " .. hovered.name
        local statusText = "Running: " .. (hovered.running and "Yes" or "No")
        local textWidth = love.graphics.getFont():getWidth(text)

        local centerX = hovered.posX + hovered.sizeX / 2
        local x = centerX - textWidth / 2

        love.graphics.print(text, x, hovered.posY - 40)
        love.graphics.print(statusText, x, hovered.posY - 20)
        love.graphics.setFont(fonts.default)
    end
end

function game.keypressed(key)
    if key == "escape" then
        if game.editing then
            exit_edit()
            print("Editing mode: OFF")
        else
            switchScene("menu")
        end
    end
end

function game.mousepressed(x, y, btn)
    if btn == 1 and not shop.visible then
        local hoveredMachine = machine.getHovered(user.floor)
        local hoveredButton = button.getHovered()

        if hoveredMachine then hoveredMachine:click() end
        if hoveredButton then hoveredButton:click() end
    end

    if btn == 1 and shop.visible then
        local hoveredButton = button.getHovered()
        if hoveredButton then hoveredButton:click() end
    end

    if btn == 2 and not shop.visible then
        local hoveredMachine = machine.getHovered(user.floor)
        if hoveredMachine then
            game.editing = true
            game.isEditing = hoveredMachine
            game.isEditingRunning = hoveredMachine.running
            print("Editing mode: " .. (game.editing and "ON" or "OFF"))
        end
    end
end

return game