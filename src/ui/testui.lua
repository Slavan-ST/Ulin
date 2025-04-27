-- TestUI.lua
local class = require("lib.middleclass")
local UIManager = require("src.ui.UIManager")
local DebugConsole = require("src.ui.DebugConsole")
local UIButton = require("src.ui.UIButton")
local UILabel = require("src.ui.UILabel")
local UILoader = require("src.ui.UILoader")
local UIInspectorPopup = require("src.ui.UIInspectorPopup")

local TestUI = class("TestUI")

function TestUI:initialize()
    self.uiManager = UIManager:new()
    DebugConsole:initialize(self.uiManager)
    self:setupTestUI()
    DebugConsole:printLog("TestUI initialized")
    
    -- Переменная для отслеживания состояния чекбокса
    self.checkboxState = false
end

function TestUI:setupTestUI()
    -- 1. Основная тестовая кнопка (с возможностью перетаскивания)
    self.testButton = UIButton:new(
        200, 200, 200, 60, 
        "Open Inspector",
        function() 
            DebugConsole:printLog("Opening inspector popup")
            self.inspectorPopup:show()
        end
    )
    self.testButton.color = {0.3, 0.6, 0.8, 1}
    self.testButton.pressedColor = {0.8, 0.3, 0.3, 1}
    self.testButton.draggable = true
    self.uiManager:add(self.testButton, 1000)
    
    -- 2. Метка (надпись)
    self.label = UILabel:new(
        50, 50,
        "UI Test Environment",
        love.graphics.newFont(24),
        {1, 1, 1, 1}
    )
    self.uiManager:add(self.label, 900)
    
    -- 3. Индикатор загрузки
    self.loader = UILoader:new(50, 100, 300, 20)
    self.loader:setShowPercentage(true)
    self.uiManager:add(self.loader, 800)
    
    -- Анимация загрузки
    self.loadProgress = 0
    self.loading = true
    
    -- 4. Всплывающее окно с информацией
    
    
  local testTarget = {
       name = "Test Object",
       position = {x = 100, y = 200},
       visible = true,
       stats = {health = 100, mana = 50}
   }
   
    
    self.inspectorPopup = UIInspectorPopup:new(
        200, 100, 300, 400, 
        "Object Inspector", 
        testTarget
    )
    self.inspectorPopup:hide() -- Скрываем по умолчанию
    self.uiManager:add(self.inspectorPopup, 1100)
    
    -- 5. Кнопка для управления лоадером
    self.loaderButton = UIButton:new(
        50, 150, 150, 40,
        "Toggle Loader",
        function()
            self.loading = not self.loading
            DebugConsole:printLog("Loader " .. (self.loading and "started" or "stopped"))
        end
    )
    self.loaderButton.color = {0.4, 0.4, 0.8, 1}
    self.uiManager:add(self.loaderButton, 950)
end

function TestUI:load()
    DebugConsole:printLog("TestUI loaded")
    DebugConsole:registerDebugObject(self, "TestUI System")
end

function TestUI:update(dt)
    self.uiManager:update(dt)
    
    -- Анимация загрузки
    if self.loading then
        self.loadProgress = self.loadProgress + dt * 0.2
        if self.loadProgress > 1 then
            self.loadProgress = 0
        end
        self.loader:setProgress(self.loadProgress)
    end
end

function TestUI:draw()
    -- Фон тестового интерфейса
    love.graphics.setColor(0.1, 0.1, 0.15)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- Подпись тестового режима
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("TEST UI MODE - Drag elements to test", 20, 20)
    
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
    
    -- Открытие/закрытие инспектора по клавише F1
    if key == "f1" then
        if self.inspectorPopup.visible then
            self.inspectorPopup:hide()
        else
            self.inspectorPopup:show()
        end
    end
end

return TestUI