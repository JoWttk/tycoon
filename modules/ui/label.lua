local task  = require("utils.task")

local label = {}
label.list = {}
label.__index = label

function label:new(text, posX, posY, color, textStroke, textStrokeColor)
    local lbl = setmetatable({
        text = text,
        posX = posX,
        posY = posY,
        color = color or {1, 1, 1},
        textStroke = textStroke or 0,
        textStrokeColor = textStrokeColor or {0, 0, 0},
        font = love.graphics.getFont()
    }, {__index = label})

    print(lbl.font)

    table.insert(label.list, lbl)
    return lbl
end

function label:draw()
    love.graphics.setColor(self.color)
    love.graphics.print(self.text, self.posX, self.posY)
end

function label.drawAll()
    for _, l in ipairs(label.list) do
        love.graphics.setFont(l.font)

        if l.textStroke > 0 then
            love.graphics.setColor(l.textStrokeColor)
            for dx = -l.textStroke, l.textStroke, l.textStroke do
                for dy = -l.textStroke, l.textStroke, l.textStroke do
                    love.graphics.print(l.text, l.posX + dx, l.posY + dy)
                end
            end
        end

        love.graphics.setColor(l.color)
        love.graphics.print(l.text, l.posX, l.posY)
    end
end

function label.tween(instance, direction, duration)
    local targetX = instance.posY + (direction == "in" and -21 or 21)
    duration = duration or 0.3
    local elapsed = 0

    local startY = instance.posY

    local tweenFunc = function(dt)
        elapsed = elapsed + dt

        local t = math.min(elapsed / duration, 1)
        instance.posY = startY + (targetX - startY) * t

        if t >= 1 then
            label.remove(instance)
            return true
        end
    end

    task.spawn(function()
        while not tweenFunc(love.timer.getDelta()) do
            task.wait(0.1)
        end
    end)
end

function label:remove(index)
    if not label.list[index] then return end
    table.remove(label.list, index)
end

function label.remove(instance)
    for i, l in ipairs(label.list) do
        if l == instance then
            table.remove(label.list, i)
            return
        end
    end
end

function label:setText(newText)
    self.text = newText
end

return label