local user = require("user")
local button = require("modules.ui.button")
local window = require("modules.ui.window")
local label = require("modules.ui.label")

local shop = {}
shop.visible = false

local items = {
    Initial = {
        name = "Initial Machine",
        price = 1000,
        label = nil,
        button = nil
    },
    Test = {
        name = "Test Machine",
        price = 150,
        label = nil,
        button = nil
    }
}

local itemOrder = { "Initial", "Test" }

local closeButton = nil
local WINDOW = nil
local shopLabel = nil

local sw, sh = love.graphics.getDimensions()

local ww, wh = 480, 520
local wx = math.floor(sw / 2 - ww / 2)
local wy = math.floor(sh / 2 - wh / 2)

local COLS        = 2
local ITEM_W      = 200
local ITEM_H      = 50
local PAD_X       = 20
local PAD_Y       = 60
local GAP_X       = 20
local GAP_Y       = 15

local function getItemPos(index)
    local col = (index - 1) % COLS
    local row = math.floor((index - 1) / COLS)
    local x = wx + PAD_X + col * (ITEM_W + GAP_X)
    local y = wy + PAD_Y + row * (ITEM_H + GAP_Y)
    return x, y
end

local function close()
    shop.unload()
end

function shop.addItem(name)
    love.graphics.setFont(fonts.small)

    local index = 1
    for i, key in ipairs(itemOrder) do
        if key == name then index = i break end
    end

    local x, y = getItemPos(index)

    items[name].label = label:new(
        items[name].name .. " - $" .. items[name].price,
        x * 1.04, y - 18, {1, 1, 1}
    )

    items[name].button = button:new(
        items[name].name .. " - $" .. items[name].price,
        x, y, ITEM_W, ITEM_H,
        function()
            if user.getMoney() >= items[name].price then
                user.takeMoney(items[name].price)

                local machineModule = require("machines." .. name:lower())
                machineModule.load()

                close()
                game_edit(machineModule.machine)
            else
                local InsufficientMoneyLabel = label:new(
                    "Not enough money!",
                    wx + ww / 2 - 80, wy + wh - 40, {1, 0.5, 0.5}
                )

                label.tween(InsufficientMoneyLabel, "in", 0.25)
            end
        end,
        {0, 1, 0}, {0, 0, 0}, 2, {1, 1, 1}
    )
end

function shop.load()
    if shop.visible then return end
    shop.visible = true

    WINDOW = window:new("Shop", wx, wy, ww, wh, {0, 0, 0}, 4, {1, 1, 1})
    WINDOW.visible = true

    for _, name in ipairs(itemOrder) do
        shop.addItem(name)
    end

    love.graphics.setFont(fonts.large)

    shopLabel = label:new("Shop", wx + ww / 2.35, wy - 10, {1, 1, 1}, 2, {0, 0, 0})

    closeButton = button:new("X", wx + ww - 35, wy + 5, 30, 30, function()
        shop.unload()
    end, {1, 0, 0}, {1, 1, 1}, 2, {1, 1, 1})
end

function shop.unload()
    if not shop.visible then return end
    shop.visible = false

    if WINDOW then window.remove(WINDOW) WINDOW = nil end

    for _, name in ipairs(itemOrder) do
        if items[name].label  then label.remove(items[name].label)   items[name].label  = nil end
        if items[name].button then button.remove(items[name].button) items[name].button = nil end
    end

    if closeButton then button.remove(closeButton) closeButton = nil end
    if shopLabel then label.remove(shopLabel) shopLabel = nil end
end

return shop