local task = require("utils.task")
local save = require("save")
local shop = require("windows.shop")

local machine = {}
machine.list = {}
machine.__index = machine

function machine:new(name, posX, posY, sizeX, sizeY, speed, work, onClick, color, floor, image, kind)
    if not name then return end
    if not posX then return end
    if not posY then return end

    local instance = setmetatable({
        name  = name,
        posX  = posX,
        posY  = posY,
        sizeX = sizeX or 50,
        sizeY = sizeY or 50,
        speed = speed or 10,
        work  = work,
        color = color or {1, 1, 1},
        baseColor = color or {1, 1, 1},
        image = image and love.graphics.newImage(image) or nil,
        hovered = false,
        running = false,
        floor = floor or 1,
        onClick = onClick,
        kind = kind or "generic"
    }, machine)

    table.insert(machine.list, instance)

    if onClick then
        onClick(instance)
    end

    if work then
        task.spawn(function()
            work(instance)
        end)
    end

    return instance
end

function machine:draw()
    if self.image then
        local scaleX = self.sizeX / self.image:getWidth()
        local scaleY = self.sizeY / self.image:getHeight()
        if self.hovered then
            love.graphics.setColor(0.8, 0.8, 1)
        else
            love.graphics.setColor(1, 1, 1)
        end
        love.graphics.draw(self.image, self.posX, self.posY, 0, scaleX, scaleY)
    else
        if self.hovered then
            love.graphics.setColor(self.color[1]*0.8, self.color[2]*0.8, self.color[3]*1)
        else
            love.graphics.setColor(self.color)
        end
        love.graphics.rectangle("fill", self.posX, self.posY, self.sizeX, self.sizeY)
    end

    love.graphics.setColor(0, 0, 0)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", self.posX, self.posY, self.sizeX, self.sizeY)
    love.graphics.setLineWidth(1)

    if self._ballTween and self._ballTween.active then
        love.graphics.setColor(self._ballTween.color)
        if self._ballTween.horizontal then
            love.graphics.circle("fill",
                self._ballTween.pos + self._ballTween.radius,
                self.posY + self.sizeY / 2,
                self._ballTween.radius)
        else
            love.graphics.circle("fill",
                self.posX + self.sizeX / 2,
                self._ballTween.pos + self._ballTween.radius,
                self._ballTween.radius)
        end
    end
end

function machine:ballTween(duration, callback)
    local startColor = {self.color[1], self.color[2], self.color[3]}
    local timer = 0
    local ballRadius = math.min(self.sizeX, self.sizeY) * 0.15
    local horizontal = self.sizeX >= self.sizeY

    local startPos, endPos
    if horizontal then
        startPos = self.posX
        endPos = self.posX + self.sizeX - ballRadius * 2
    else
        startPos = self.posY
        endPos = self.posY + self.sizeY - ballRadius * 2
    end

    self._ballTween = {
        active = true,
        pos = startPos,
        horizontal = horizontal,
        color = {1, 1, 1},
        radius = ballRadius
    }

    while timer < duration do
        if not self.running then
            self._ballTween.active = false
            return
        end

        local dt = coroutine.yield()
        timer = timer + (dt or 0)

        local t = math.min(timer / duration, 1)
        self._ballTween.pos = startPos + (endPos - startPos) * t
    end

    self._ballTween.active = false
    if callback then callback(self) end
end

function machine:isHovered(mx, my)
    if shop.visible then return false end
    return mx >= self.posX and mx <= self.posX + self.sizeX and my >= self.posY and my <= self.posY + self.sizeY
end

function machine:updateHover(mx, my)
    self.hovered = self:isHovered(mx, my)
end

function machine:click()
    if self.onClick then
        self.onClick(self)
    end
end

function machine.drawAll(floorFilter)
    for _, m in ipairs(machine.list) do
        if floorFilter and m.floor ~= floorFilter then goto continue end
        m:draw()
        ::continue::
    end
end

function machine.updateAllHover(mx, my, floorFilter)
    for _, m in ipairs(machine.list) do
        if floorFilter and m.floor ~= floorFilter then
            m.hovered = false
        else
            m:updateHover(mx, my)
        end
    end
end

function machine.getHovered(floorFilter)
    for _, m in ipairs(machine.list) do
        if floorFilter and m.floor ~= floorFilter then goto continue end
        if m.hovered then return m end
        ::continue::
    end
    return nil
end

function machine:set(index, properties)
    if not machine.list[index] then return end
    for key, value in pairs(properties) do
        machine.list[index][key] = value
    end
end

function machine:setColor(r,g,b)
    self.color = {r, g, b}
end

function machine:get(index)
    return machine.list[index]
end

function machine:remove(index)
    if not machine.list[index] then return end
    table.remove(machine.list, index)
end

function machine:isOverlapping(other)
    return self.posX < other.posX + other.sizeX and
           self.posX + self.sizeX > other.posX and
           self.posY < other.posY + other.sizeY and
           self.posY + self.sizeY > other.posY
end

function machine.canPosition(posX, posY, sizeX, sizeY, excludeInstance)
    for _, m in ipairs(machine.list) do
        if excludeInstance and m == excludeInstance then goto continue end
        
        if posX < m.posX + m.sizeX and
           posX + sizeX > m.posX and
           posY < m.posY + m.sizeY and
           posY + sizeY > m.posY then
            return false
        end
        
        ::continue::
    end
    return true
end

function machine:move(x,y)
    if not machine.canPosition(self.posX + x, self.posY + y, self.sizeX, self.sizeY, self) then 
        return 
    end

    self.posX = self.posX + x
    self.posY = self.posY + y
    save.save()
end

function machine:setRunning(boolean)
    self.running = boolean
    save.save()
end

function machine:getRunning()
    return self.running
end

return machine