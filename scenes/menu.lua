local menu = {}

function menu.load()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1)
end

function menu.update(dt)
end

function menu.draw()
    love.graphics.setColor(1, 1, 1)
    local w, h = love.graphics.getDimensions()
    local font = love.graphics.getFont()
    local text = "Menu - Pressione Enter para jogar"
    local textW = font:getWidth(text)
    local textH = font:getHeight()

    love.graphics.print(text, w/2 - textW/2, h/2 - textH/2)
end

function menu.keypressed(key)
    if key == "return" then
        switchScene("game") 
    end
end

return menu