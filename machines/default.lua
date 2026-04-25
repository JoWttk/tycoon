local machine = require("modules.machine")
local user = require("user")
local task = require("utils.task")

local default = {}

function default.load(state)
    local posX = state and state.posX or 200
    local posY = state and state.posY or 150
    local sizeX = state and state.sizeX or 300
    local sizeY = state and state.sizeY or 50
    local speed = state and state.speed or 2
    local floorNum = state and state.floor or user.floor

    default.machine = machine:new(
        state and state.name or "Outro teste",
        posX, posY, sizeX, sizeY, speed,
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
        {0, 0, 1},
        floorNum,
        nil,
        "default"
    )

    if state and state.running then
        default.machine:setRunning(true)
    end

    return default.machine
end

return default

