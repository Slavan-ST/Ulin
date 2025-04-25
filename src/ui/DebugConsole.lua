local class = require("lib.middleclass")
local UIManager = require("src.ui.UIManager")
local UIInspectorPopup = require("src.ui.UIInspectorPopup")

local DebugConsole = class("DebugConsole")




-- Единый экземпляр консоли
local instance = nil

-- Стили консоли
local style = {
    bg = {0.1, 0.1, 0.15, 0.95},
    text = {0.9, 0.9, 0.9},
    input = {0.15, 0.15, 0.2, 0.9},
    button = {
        normal = {0.2, 0.2, 0.3, 0.9},
        hover = {0.3, 0.3, 0.4, 0.9}
    }
}

-- Данные консоли
local debugObjects = {}
local debugLogs = {}
local commandHistory = {}
local currentCommand = ""
local isVisible = false
local inputFocus = false
local uiManager = UIManager:new()

-- В начало файла (после других local переменных)
local closeButton = {
    x = 10, y = 305, width = 80, height = 20,
    draw = function(self)
        love.graphics.setColor(style.button.normal)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 3)
        love.graphics.setColor(style.text)
        love.graphics.print("Close", self.x + 10, self.y + 3)
    end,
    touchpressed = function(self, x, y)
        if x >= self.x and x <= self.x + self.width and
           y >= self.y and y <= self.y + self.height then
            isVisible = false
            return true
        end
        return false
    end
}

function DebugConsole:initialize()
    if instance then
        return instance
    end
    instance = self
    return self
end

function DebugConsole.printLog(message)
    table.insert(debugLogs, tostring(message))
    if #debugLogs > 100 then
        table.remove(debugLogs, 1)
    end
end

function DebugConsole.registerDebugObject(obj, name)
    name = name or "obj_"..#debugObjects+1
    local popup = UIInspectorPopup:new(200, 100, 350, 450, name, obj)
    uiManager:add(popup)
    table.insert(debugObjects, {obj = obj, popup = popup})
    return popup
end

function DebugConsole.update(dt)
    if isVisible then
        uiManager:update(dt)
    end
end

function DebugConsole.draw()
    if not isVisible then return end
    
    -- Фон консоли
    love.graphics.setColor(style.bg)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 300)
    
    -- Логи
    love.graphics.setColor(style.text)
    for i = math.max(1, #debugLogs-15), #debugLogs do
        love.graphics.print(debugLogs[i], 10, 10 + (i-1)*20)
    end
    
    -- Поле ввода
    love.graphics.setColor(style.input)
    love.graphics.rectangle("fill", 0, 300, love.graphics.getWidth(), 30)
    love.graphics.setColor(style.text)
    love.graphics.print("> "..currentCommand, 10, 305)
    
    -- UI элементы
    -- В функцию draw() добавить перед uiManager:draw()
    closeButton:draw()

    uiManager:draw()
end


function DebugConsole.executeCommand(cmd)
    table.insert(commandHistory, cmd)
    DebugConsole.printLog("> "..cmd)
    
    if cmd == "clear" then
        debugLogs = {}
    else
        DebugConsole.printLog("Command executed: "..cmd)
    end
end

function DebugConsole.processTouchPress(id, x, y)
    -- Открытие консоли (левый верхний угол)
    if not isVisible and y < 50 and x < 150 then
        isVisible = true
        inputFocus = false
        return true  -- Событие обработано
    end
    
    if not isVisible then return false end  -- Консоль не видна - не обрабатываем
    
    -- Проверка кнопки закрытия
    if closeButton:touchpressed(x, y) then
        return true
    end
    
    -- Сначала даем возможность UI элементам обработать клик
    if uiManager:touchpressed(id, x, y) then
        return true
    end
    
    -- Затем проверяем поле ввода
    inputFocus = (y >= 300 and y <= 330)
    
    -- Если клик был в области консоли, но не на элементах - возвращаем true
    return y <= 300
end

function DebugConsole.processTextInput(text)
    -- Только если фокус ввода и консоль видима
    if isVisible and inputFocus then
        currentCommand = currentCommand .. text
        return true
    end
    return false
end

function DebugConsole.processKeyPress(key)
    -- Глобальные горячие клавиши работают всегда
    if key == "f1" then
        isVisible = not isVisible
        return true
    end
    
    -- Эти клавиши работают только когда консоль видима
    if isVisible then
        if key == "escape" then
            isVisible = false
            return true
        end
        
        if inputFocus then
            if key == "backspace" then
                currentCommand = currentCommand:sub(1, -2)
                return true
            elseif key == "return" then
                DebugConsole.executeCommand(currentCommand)
                currentCommand = ""
                return true
            end
        end
    end
    
    return false
end
-- Возвращаем сам класс, а не экземпляр
return DebugConsole