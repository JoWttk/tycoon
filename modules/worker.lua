local worker = {}
worker.list = {}
worker.__index = worker

function worker:new(name, posX, posY, sizeX, sizeY, work, color, image)
    if not name then return end
    if not posX then return end
    if not posY then return end

    local instance = setmetatable({
        name  = name,
        posX  = posX,
        posY  = posY,
        sizeX = sizeX or 50,
        sizeY = sizeY or 50,
        work  = work,
        color = color or {1, 1, 1},
        image = image and love.graphics.newImage(image) or nil
    }, worker)

    table.insert(worker.list, instance)

    if work then
        work()
    end

    return instance
end

function worker:draw()
    if self.image then
        local scaleX = self.sizeX / self.image:getWidth()
        local scaleY = self.sizeY / self.image:getHeight()
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(self.image, self.posX, self.posY, 0, scaleX, scaleY)
    else
        love.graphics.setColor(self.color)
        love.graphics.rectangle("fill", self.posX, self.posY, self.sizeX, self.sizeY)
    end
end

function worker:drawAll()
    for _, w in ipairs(worker.list) do
        if w.image then
            local scaleX = w.sizeX / w.image:getWidth()
            local scaleY = w.sizeY / w.image:getHeight()
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(w.image, w.posX, w.posY, 0, scaleX, scaleY)
        else
            love.graphics.setColor(w.color)
            love.graphics.rectangle("fill", w.posX, w.posY, w.sizeX, w.sizeY)
        end
    end
end

function worker:remove(index)
    if not worker.list[index] then return end
    table.remove(worker.list, index)
end

return worker