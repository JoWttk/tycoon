local button = {}
button.list = {}
button.__index = button

function button:new(name, posX, posY, sizeX, sizeY, onClick, color, textColor, stroke, strokeColor, font)
    local btn = setmetatable({
        name = name,
        posX = posX,
        posY = posY,
        sizeX = sizeX,
        sizeY = sizeY,
        color = color or {1, 1, 1},
        textColor = textColor or {0, 0, 0},
        hovered = false,
        stroke = stroke or 0,
        strokeColor = strokeColor or {0, 0, 0},
        onClick = onClick,
        font = love.graphics.getFont(),
    }, {__index = button})

    table.insert(button.list, btn)
    return btn
end

function button:draw()
    if self.hovered then
        love.graphics.setColor(self.color[1]*0.8, self.color[2]*0.8, self.color[3]*1)
    else
        love.graphics.setColor(self.color)
    end
    love.graphics.rectangle("fill", self.posX, self.posY, self.sizeX, self.sizeY)
end

function button.drawAll()
    for _, b in ipairs(button.list) do
        if b.hovered then
            love.graphics.setColor(b.color[1]*0.8, b.color[2]*0.8, b.color[3]*1)
        else
            love.graphics.setColor(b.color)
        end

        love.graphics.rectangle("fill", b.posX, b.posY, b.sizeX, b.sizeY)

        if b.stroke > 0 then
            love.graphics.setColor(b.strokeColor)
            love.graphics.setLineWidth(b.stroke)
            love.graphics.rectangle("line", b.posX, b.posY, b.sizeX, b.sizeY)
            love.graphics.setLineWidth(1)
        end

        local font = b.font
        local textW = font:getWidth(b.name)
        local textH = font:getHeight()
        local tx = b.posX + (b.sizeX - textW) / 2
        local ty = b.posY + (b.sizeY - textH) / 2

        love.graphics.setFont(font)

        love.graphics.setColor(b.textColor)
        love.graphics.print(b.name, tx, ty)

        love.graphics.setFont(fonts.default)
    end
end

function button.updateAllHover(mx, my)
    for _, b in ipairs(button.list) do
        b:updateHover(mx, my)
    end
end

function button:isHovered(mx, my)
    return mx >= self.posX and mx <= self.posX + self.sizeX and
           my >= self.posY and my <= self.posY + self.sizeY
end

function button:updateHover(mx, my)
    self.hovered = self:isHovered(mx, my)
end

function button.getHovered()
    for _, b in ipairs(button.list) do
        if b.hovered then return b end
    end
    return nil
end

function button.remove(instance)
    for i, b in ipairs(button.list) do
        if b == instance then
            table.remove(button.list, i)
            return
        end
    end
end

function button:click()
    if self.onClick then
        self.onClick(self)
    end
end

return button