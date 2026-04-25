local save = require("save")
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
    
    local saveData = save.load()
    if saveData then
        local delete_text = "Pressione Backspace para deletar o save"
        local deleteW = font:getWidth(delete_text)

        love.graphics.print(delete_text, w/2 - deleteW/2, h/2 + textH/2 + 20)
    else
        local noSaveInfo = "Nenhum save encontrado"
        local noSaveW = font:getWidth(noSaveInfo)
        love.graphics.print(noSaveInfo, w/2 - noSaveW/2, h/2 + textH + 20)
    end
end

function menu.keypressed(key)
    if key == "return" then
        switchScene("game")
    elseif key == "backspace" then
        if save.delete() then
            print("Save deleted")
        else
            print("No save file to delete")
        end
    end
end

return menu