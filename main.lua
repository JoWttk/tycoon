CURRENT_SCENE = "menu"
local scene = nil

local task = require("utils.task")

fonts = {
    small = love.graphics.newFont("assets/fonts/PressStart2P-Regular.ttf", 8),
    small2 = love.graphics.newFont("assets/fonts/PressStart2P-Regular.ttf", 12),
    default = love.graphics.newFont("assets/fonts/PressStart2P-Regular.ttf", 14),
    large = love.graphics.newFont("assets/fonts/PressStart2P-Regular.ttf", 18)
}

local function loadScene(name)
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setFont(fonts.default)

    package.loaded["scenes." .. name] = nil

    local ok, mod = pcall(require, "scenes." .. name)
    if not ok then
        print("Erro ao carregar cena '" .. name .. "': " .. mod)
        return nil
    end
    if ok and type(mod) == "table" then
        return mod
    end

    return nil
end

local function changeScene(name)
    scene = loadScene(name)
    if scene and scene.load then
        scene.load()
    end
end

function love.load()
    changeScene(CURRENT_SCENE)
end

function love.update(dt)
    task.update(dt)

    if scene and scene.update then
        scene.update(dt)
    end
end

function love.draw()
    if scene and scene.draw then
        scene.draw()
    end
end

function love.keypressed(key)
    if scene and scene.keypressed then
        scene.keypressed(key)
    end
end

function love.mousepressed(x, y, button)
    if scene and scene.mousepressed then
        scene.mousepressed(x, y, button)
    end
end

function switchScene(name)
    CURRENT_SCENE = name
    changeScene(name)
end