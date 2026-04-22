local machine = require("modules.machine")
local task = require("utils.task")
local user = require("user")
local button = require("modules.ui.button")
local shop = require("windows.shop")

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

function game.load()
    love.graphics.setBackgroundColor(0.3, 0.3, 0.3)
    machine.list = {}

    user.load()
    
    -- Set up floor change callback to move editing machine
    user.onFloorChange = function(floorNum)
        if game.editing and game.isEditing then
            game.isEditing.floor = floorNum
        end
    end

    OutroTeste=machine:new(
        "Outro teste",
        200, 150, 300, 50, 2,
        function(self)
            task.wait(2)

            while true do
                if self.running then
                    self:ballTween(1 * self.speed, function()
                        user.addMoney(100)
                    end)
                    task.wait(5)
                else
                    task.wait(0.1)
                end
            end
        end,
        function(self)
            self:setRunning(not self.running)
            print(self.running)
        end,
        {0, 0, 1}
    )
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