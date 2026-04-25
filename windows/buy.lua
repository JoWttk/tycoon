local buy = {}

local save = require("save")
local button = require("modules.ui.button")
local window = require("modules.ui.window")
local label = require("modules.ui.label")

local sw, sh = love.graphics.getDimensions()
local ww, wh = 480, 520
local wx = math.floor(sw / 2 - ww / 2)
local wy = math.floor(sh / 2 - wh / 2)

function buy.load(item, price, floorNum)
    local user = require("user")

    buy.item = item
    buy.window = window:new(
        "Buy " .. item,
        400, 300, 300, 150,
        function() end
    )

    buy.label = label:new(
        "Would you like to buy " .. item .. " for $" .. price .. "?",
        410, 320,
        {0, 0, 0}
    )

    buy.button = button:new(
        "Buy",
        410, 360, 80, 30,
        function()
            if user.getMoney() >= price then
                user.takeMoney(price)
                user.machines[item] = true

                if floorNum then
                    user.unlockFloor(floorNum)
                end

                buy.unload()
                save.save()
            else
                local InsufficientMoneyLabel = label:new(
                    "Not enough money!",
                    wx + ww / 2 - 80, wy + wh - 40, {1, 0.5, 0.5}
                )

                label.tween(InsufficientMoneyLabel, "in", 0.25)
            end
        end,
        {0.5, 0.5, 0.5}, {1, 1, 1}, 2, {0,0,0}
    )

    buy.cancel = button:new(
        "Cancel",
        500, 360, 80, 30,
        function()
            buy.unload()
        end,
        {0.5, 0.5, 0.5}, {1, 1, 1}, 2, {0,0,0}
    )
end

function buy.unload()
    if buy.button then button.remove(buy.button) buy.button = nil end
    if buy.label then label.remove(buy.label) buy.label = nil end
    if buy.window then window.remove(buy.window) buy.window = nil end
    if buy.cancel then button.remove(buy.cancel) buy.cancel = nil end
end

return buy