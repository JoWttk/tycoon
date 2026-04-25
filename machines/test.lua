local machine = require("modules.machine")
local user = require("user")
local task = require("utils.task")

local test = {}

function test.load(state)
    local posX = state and state.posX or 300
    local posY = state and state.posY or 120
    local sizeX = state and state.sizeX or 100
    local sizeY = state and state.sizeY or 200
    local speed = state and state.speed or 1
    local floorNum = state and state.floor or user.floor

    test.machine = machine:new(
        "Test Machine",
        posX, posY, sizeX, sizeY, speed,
        function(self)
            while true do
                if self.running then
                    self:ballTween(1 * self.speed, function()
                        user.addMoney(15)
                    end)
                    task.wait(4)
                else
                    task.wait(0.1)
                end
            end
        end,
        function(self)
            self:setRunning(not self.running)
            print(self.running)
        end,
        {0, 1, 0},
        floorNum,
        nil,
        "test"
    )

    if state and state.running then
        test.machine:setRunning(true)
    end

    return test.machine
end
