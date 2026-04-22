local machine = require("modules.machine")
local user = require("user")
local task = require("utils.task")

local initial = {}

function initial.load()
    initial.machine = machine:new(
        "Test Machine",
        100, 100, 100, 200, 1,
        function(self)
            while true do
                if self.running then
                    self:ballTween(1 * self.speed, function()
                        user.addMoney(10)
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
        {1, 0, 0},
        user.floor
    )
end

return initial