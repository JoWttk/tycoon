local save = require("save")
local button = require("modules.ui.button")
local label = require("modules.ui.label")
local buy = require("windows.buy")
local window = require("modules.ui.window")

local user = {}

local floor = {}
local unlockedFloors = {
    [1] = true,
    [2] = false,
    [3] = false,
}

user.money = 1000
user.machines = {}
user.floor = 1

function user.setFloor(floorNum)
    if not unlockedFloors[floorNum] then
        buy.load("Floor " .. floorNum, floorNum * 2, floorNum)
        return 
    end
    user.floor = floorNum
    
    if user.onFloorChange then
        user.onFloorChange(floorNum)
    end
    
    for i, btn in pairs(floor) do
        btn.textColor = {0, 0, 0}
    end
    if floor[floorNum] then
        floor[floorNum].textColor = {1, 1, 1}
    end

    save.save()
end

function user.unlockFloor(floorNum)
    unlockedFloors[floorNum] = true
    save.save()
end

function user.isFloorUnlocked(floorNum)
    return unlockedFloors[floorNum] or false
end

function user.getCurrentFloor()
    return user.floor
end

local Money
local Shop

function user.getSaveData()
    local unlocked = {}
    for k, v in pairs(unlockedFloors) do
        unlocked[k] = v
    end

    local machines = {}
    for k, v in pairs(user.machines) do
        machines[k] = v
    end

    return {
        money = user.money,
        floor = user.floor,
        unlockedFloors = unlocked,
        machines = machines,
    }
end

function user.restoreFromSave(data)
    if not data then
        return
    end

    user.money = data.money or user.money
    user.floor = data.floor or user.floor

    if type(data.unlockedFloors) == "table" then
        for k, v in pairs(data.unlockedFloors) do
            unlockedFloors[k] = v
        end
    end

    local machineData = data.ownedMachines
    if not machineData and type(data.machines) == "table" then
        local isMap = false
        for key in pairs(data.machines) do
            if type(key) ~= "number" then
                isMap = true
                break
            end
        end
        if isMap then
            machineData = data.machines
        end
    end

    if type(machineData) == "table" then
        user.machines = {}
        for k, v in pairs(machineData) do
            user.machines[k] = v
        end
    end

    if Money then
        Money:setText("Money: $" .. user.money)
    end

    if floor[user.floor] then
        user.setFloor(user.floor)
    end
end

function user.load()
    local windows = {
        shop = require("windows.shop")
    }

    floor[1] = button:new(
        "1",
        127 + 30, 675, 50, 30,
        function() user.setFloor(1) end,
        {0.5, 0.5, 0.5}, {1, 1, 1}, 4, nil, true
    )
    
    floor[2] = button:new(
        "2",
        187 + 30, 675, 50, 30,
        function() user.setFloor(2) end,
        {0.3, 0.3, 0.3}, {0.5, 0.5, 0.5}, 4, nil, false
    )
    
    floor[3] = button:new(
        "3",
        247 + 30, 675, 50, 30,
        function() user.setFloor(3) end,
        {0.3, 0.3, 0.3}, {0.5, 0.5, 0.5}, 4, nil, false
    )

    Money = label:new("Money: $" .. user.money, 15, 15, {1, 1, 0})
    Shop = button:new("Shop", 20, 675, 100, 30, function()
        windows.shop.load()
    end, {0, 1, 1}, {0,0,0}, 2, {1,1,1})
end

function user.update(dt)
    local mx, my = love.mouse.getPosition()
    button.updateAllHover(mx, my)
    
    for i, btn in pairs(floor) do
        if user.isFloorUnlocked(i) then
            btn.color = {0.5, 0.5, 0.5}
        else
            btn.color = {0.3, 0.3, 0.3}
        end
        
        if i == user.floor then
            btn.textColor = {1, 1, 1}
        else
            btn.textColor = {0,0,0}
        end
    end
end

function user.draw()
    window.drawAll()
    label.drawAll()
    button.drawAll()
end

function user.getMoney()
    return user.money
end

function user.addMoney(amount)
    user.money = user.money + amount
    Money:setText("Money: $" .. user.money)
    save.save()
end

function user.takeMoney(amount)
    user.money = user.money - amount
    Money:setText("Money: $" .. user.money)
    save.save()
end

return user