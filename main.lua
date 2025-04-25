
local loader = require("src.core.loader")
local DebugLog = require("src.utils.debuglog")
local Fonts = require("src.ui.fonts.init")
local DebugConsole = require("src.ui.DebugConsole")


local useTestUI = true

local MTestUI = require("src.ui.testui")
local TestUI = MTestUI:new()

function love.load()
    DebugLog.init()
    DebugConsole.printLog("System initialized")
    
    Fonts.load()
    love.graphics.setFont(Fonts.default)

    if useTestUI then
        
        TestUI.load()
    else
        loader.load()
    end
end

function love.update(dt)
    DebugConsole.update(dt)
    if useTestUI then
        TestUI:update(dt)
    else
        loader.update(dt)
    end
end

function love.draw()
    if useTestUI then
        TestUI:draw()
    else
        loader.draw()
    end
    DebugConsole.draw()
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    if DebugConsole.processTouchPress(id, x, y) then return end
    
    if useTestUI then
        TestUI:touchpressed(id, x, y, dx, dy, pressure)
    else
        loader.touchpressed(id, x, y, dx, dy, pressure)
    end
end

function love.touchmoved(id, x, y, dx, dy, pressure)
    --console:processTouchMove(id, x, y, dx, dy, pressure)
    
    if useTestUI then
        print ""
        TestUI:touchmoved(id, x, y, dx, dy, pressure)
    else
        loader.touchmoved(id, x, y, dx, dy, pressure)
    end
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    --console:processTouchRelease(id, x, y, dx, dy, pressure)
    
    if useTestUI then
        print ""
        TestUI:touchreleased(id, x, y, dx, dy, pressure)
    else
        loader.touchreleased(id, x, y, dx, dy, pressure)
    end
end

function love.textinput(text)
    if not DebugConsole.processTextInput(text) then
        if useTestUI then
            TestUI:textinput(text)
        else
            loader.textinput(text)
        end
    end
end

function love.keypressed(key)
    if not DebugConsole.processKeyPress(key) then
        if useTestUI then
            TestUI:keypressed(key)
        else
            loader.keypressed(key)
        end
    end
end

