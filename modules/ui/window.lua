local window = {}
window.list = {}
window.__index= window

function window:new(name, posX, posY, sizeX, sizeY, color, stroke, strokeColor)
    local win = setmetatable({
        name = name,
        posX = posX,
        posY = posY,
        sizeX = sizeX,
        sizeY = sizeY,
        stroke = stroke or 0,
        strokeColor = strokeColor or {0, 0, 0},
        color = color or {0.2, 0.2, 0.2},
        visible = false
    }, {__index = window})

    table.insert(window.list, win)
    return win
end

function window:draw()
    if not self.visible then return end

    if self.stroke > 0 then
        love.graphics.setColor(self.strokeColor)
        love.graphics.setLineWidth(self.stroke)
        love.graphics.rectangle("line", self.posX, self.posY, self.sizeX, self.sizeY)
        love.graphics.setLineWidth(1)
    end
    
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", self.posX, self.posY, self.sizeX, self.sizeY)
end

function window.drawAll()
    for _, w in ipairs(window.list) do
        w:draw()
    end
end

function window.remove(instance)
    for i, w in ipairs(window.list) do
        if w == instance then
            table.remove(window.list, i)
            return
        end
    end
end 

return window