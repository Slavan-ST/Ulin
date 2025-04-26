-- TestUI.lua
local class = require("lib.middleclass")
local UIManager = require("src.ui.UIManager")
local DebugConsole = require("src.ui.DebugConsole")
local UIButton = require("src.ui.UIButton")
local UIInspectorPopup = require("src.ui.UIInspectorPopup")

local TestUI = class("TestUI")

function TestUI:initialize()
    self.uiManager = UIManager:new()
    DebugConsole:initialize(self.uiManager) -- Передаем менеджер в консоль
    self:setupTestUI()
    DebugConsole:printLog("TestUI initialized")
end

function TestUI:setupTestUI()
    -- Создаем тестовую кнопку с высоким zIndex (чтобы была поверх)
    self.testButton = UIButton:new(
        200, 200, 200, 60, 
        "Test Button",
        function() 
            DebugConsole:printLog("Button pressed!") 
        end
    )
    self.testButton.color = {0.3, 0.6, 0.8}
    self.testButton.pressedColor = {0.8, 0.3, 0.3}
    
    -- Добавляем с явным указанием zIndex
    self.uiManager:add(self.testButton, 1000)
    
    -- Попап с меньшим zIndex (будет под кнопкой)
    local style = {
        bg = {0.1, 0.1, 0.15, 0.95},
        text = {0.9, 0.9, 0.9},
        input = {0.15, 0.15, 0.2, 0.9},
        button = {
            normal = {0.2, 0.2, 0.3, 0.9},
            hover = {0.3, 0.3, 0.4, 0.9}
        }
    }
    local popup = UIInspectorPopup:new(200, 100, 200, 280, "player", style)
    self.uiManager:add(popup, 500) -- Средний zIndex
end

function TestUI:load()
    DebugConsole:printLog("TestUI loaded")
    DebugConsole:registerDebugObject(self, "TestUI System")
end

function TestUI:update(dt)
    self.uiManager:update(dt)
end

function TestUI:draw()
    -- Фон тестового интерфейса
    love.graphics.setColor(0.1, 0.1, 0.15)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- Подпись тестового режима
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("TEST UI MODE", 20, 20)
    
    -- Отрисовка UI элементов
    self.uiManager:draw()
end

-- Обработчики ввода
function TestUI:touchpressed(id, x, y, dx, dy, pressure)
    self.uiManager:touchpressed(id, x, y, dx, dy, pressure)
end

function TestUI:touchmoved(id, x, y, dx, dy, pressure)
    self.uiManager:touchmoved(id, x, y, dx, dy, pressure)
end

function TestUI:touchreleased(id, x, y, dx, dy, pressure)
    self.uiManager:touchreleased(id, x, y, dx, dy, pressure)
end

function TestUI:textinput(text)
    self.uiManager:textinput(text)
end

function TestUI:keypressed(key)
    self.uiManager:keypressed(key)
end

return TestUI