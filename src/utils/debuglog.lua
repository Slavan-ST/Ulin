-- src/utils/debuglog.lua
local ConsoleManager = require("src.utils.ConsoleManager")
local DebugLog = {
    logs = {},
    maxLines = 100,
    visible = false,
    scroll = 0,
    button = { x = 10, y = 10, w = 50, h = 50 },
    inputText = "",
    inputActive = false,
    settingsVisible = false,
    commandHistory = {},
    historyIndex = 0,
    scrollTouchId = nil,
    lastTouchY = 0,
    autoScroll = true,
    
    settings = {
        showFPS = true,
        showPhysics = false,
        showPlayerInfo = true,
        enableCheats = false
    },
    
    font = nil
}
-- Где-то при инициализации DebugLog добавьте:
DebugLog.sortedSettings = {
    "showFPS", 
    "showPhysics", 
    "showPlayerInfo", 
    "enableCheats"
    -- Можно добавлять новые настройки здесь
}
DebugLog.settingsScroll = 0

-- Инициализация
function DebugLog.init()
    DebugLog.font = love.graphics.newFont(12)
end

-- Добавление сообщения
function DebugLog.print(str)

    local message = tostring(str or "nil")
    table.insert(DebugLog.logs, message)
    
    if #DebugLog.logs > DebugLog.maxLines then
        table.remove(DebugLog.logs, 1)
    end
    
    if DebugLog.autoScroll then
        DebugLog.scroll = 0
    end
end

-- Отрисовка консоли
function DebugLog.draw()
    if not DebugLog.visible then
        -- Кнопка открытия
        love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
        love.graphics.rectangle("fill", DebugLog.button.x, DebugLog.button.y, 
                              DebugLog.button.w, DebugLog.button.h)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(">", DebugLog.button.x + 15, DebugLog.button.y + 15)
        return
    end

    local consoleHeight = love.graphics.getHeight() * 0.5
    local consoleWidth = love.graphics.getWidth()
    
    -- Фон консоли
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, consoleWidth, consoleHeight)


    love.graphics.setScissor(0, 0, consoleWidth - 15, consoleHeight - 30)
    love.graphics.setColor(1, 1, 1)
    
    local lineHeight = DebugLog.font:getHeight() + 2
    local visibleLines = math.floor((consoleHeight - 30) / lineHeight)
    
    for i = 0, visibleLines - 1 do
        local logIndex = #DebugLog.logs - visibleLines + i - math.floor(DebugLog.scroll)
        if logIndex > 0 and DebugLog.logs[logIndex] then
                -- Отрисовка логов
            if DebugLog.logs[logIndex]:lower():find("error") then
                love.graphics.setColor(1, 0.3, 0.3)
            elseif DebugLog.logs[logIndex]:lower():find("warning") then
                love.graphics.setColor(1, 1, 0.4)
            else
                love.graphics.setColor(1, 1, 1)
            end
            love.graphics.print(DebugLog.logs[logIndex], 10, 10 + i * lineHeight)
        end
    end
    love.graphics.setScissor()

    -- Панель ввода
    love.graphics.setColor(0.3, 0.3, 0.3, 0.9)
    love.graphics.rectangle("fill", 0, consoleHeight - 30, consoleWidth, 30)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("> "..DebugLog.inputText, 20, consoleHeight - 25)
    
    -- Кнопки управления
    love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
    love.graphics.rectangle("fill", DebugLog.button.x, DebugLog.button.y, DebugLog.button.w, DebugLog.button.h)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("X", DebugLog.button.x + 15, DebugLog.button.y + 15)
    
    -- Кнопка настроек
    love.graphics.rectangle("fill", DebugLog.button.x + DebugLog.button.w + 10, DebugLog.button.y, 
                          DebugLog.button.w, DebugLog.button.h)
    love.graphics.print("⚙", DebugLog.button.x + DebugLog.button.w + 25, DebugLog.button.y + 15)
    
    -- Окно настроек
    if DebugLog.settingsVisible then
        DebugLog.drawSettings()
    end
    
    -- Кнопки истории команд
    if DebugLog.inputActive then
        DebugLog.drawHistoryButtons()
    end
end

-- Кнопки истории команд
function DebugLog.drawHistoryButtons()
    local buttonY = love.graphics.getHeight() * 0.5 - 70
    local buttonSize = 40
    
    -- Кнопка "вверх"
    love.graphics.setColor(0.3, 0.3, 0.5, 0.7)
    love.graphics.rectangle("fill", 20, buttonY, buttonSize, buttonSize)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("↑", 35, buttonY + 10)
    
    -- Кнопка "вниз"
    love.graphics.setColor(0.3, 0.3, 0.5, 0.7)
    love.graphics.rectangle("fill", 70, buttonY, buttonSize, buttonSize)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("↓", 85, buttonY + 10)
end

-- Обработка касаний
function DebugLog.touchpressed(id, x, y)
    -- Если открыты настройки - обрабатываем только их
    if DebugLog.settingsVisible then
        DebugLog.handleSettingsTouch(x, y)
        return
    end

    -- Кнопка закрытия
    if x >= DebugLog.button.x and x <= DebugLog.button.x + DebugLog.button.w and
       y >= DebugLog.button.y and y <= DebugLog.button.y + DebugLog.button.h then
        DebugLog.visible = not DebugLog.visible
        DebugLog.hideKeyboard()
        return
    end

    -- Кнопка настроек
    if x >= DebugLog.button.x + DebugLog.button.w + 10 and 
       x <= DebugLog.button.x + DebugLog.button.w * 2 + 10 and
       y >= DebugLog.button.y and y <= DebugLog.button.y + DebugLog.button.h then
        DebugLog.settingsVisible = not DebugLog.settingsVisible
        return
    end

    -- Поле ввода
    if y > love.graphics.getHeight() * 0.5 - 30 then
        DebugLog.inputActive = true
        love.keyboard.setTextInput(true, 0, love.graphics.getHeight() * 0.5 - 30, 
                                 love.graphics.getWidth(), 30)
        return
    end

    -- Кнопки истории команд
    if DebugLog.inputActive then
        local buttonY = love.graphics.getHeight() * 0.5 - 70
        if y >= buttonY and y <= buttonY + 40 then
            if x >= 20 and x <= 60 then  -- Вверх
                if DebugLog.historyIndex > 1 then
                    DebugLog.historyIndex = DebugLog.historyIndex - 1
                    DebugLog.inputText = DebugLog.commandHistory[DebugLog.historyIndex]
                end
            elseif x >= 70 and x <= 110 then  -- Вниз
                if DebugLog.historyIndex < #DebugLog.commandHistory then
                    DebugLog.historyIndex = DebugLog.historyIndex + 1
                    DebugLog.inputText = DebugLog.commandHistory[DebugLog.historyIndex] or ""
                end
            end
            return
        end
    end

    -- Начало прокрутки
    DebugLog.scrollTouchId = id
    DebugLog.lastTouchY = y
end


function DebugLog.touchmoved(id, x, y)
    if DebugLog.scrollTouchId == id then
        DebugLog.autoScroll = false
        local dy = y - DebugLog.lastTouchY
        DebugLog.scroll = math.min(DebugLog.getMaxScroll(), math.max(-3, DebugLog.scroll - dy * 0.5))
        DebugLog.lastTouchY = y
    end
end

function DebugLog.touchreleased(id, x, y)
    if id == DebugLog.scrollTouchId then
        DebugLog.scrollTouchId = nil
    end
end

-- Управление клавиатурой
function DebugLog.hideKeyboard()
    if DebugLog.inputActive then
        DebugLog.inputActive = false
        love.keyboard.setTextInput(false)
    end
end

-- Ввод текста
function DebugLog.textinput(t)
    if DebugLog.inputActive then
        DebugLog.inputText = DebugLog.inputText .. t
    end
end

-- Обработка клавиш (для Android)
function DebugLog.keypressed(key)
    if not DebugLog.inputActive then return end

    -- Кнопка назад на Android
    if key == "backspace" then
        DebugLog.inputText = DebugLog.inputText:sub(1, -2)
    
    -- Кнопка "Готово" на Android-клавиатуре
    elseif key == "return" then
        table.insert(DebugLog.commandHistory, DebugLog.inputText)
        DebugLog.historyIndex = #DebugLog.commandHistory + 1
        
        DebugLog.print("> "..DebugLog.inputText)
        local success, result = ConsoleManager:execute(DebugLog.inputText)
        
        if result == "_CLEAR_CONSOLE" then
            DebugLog.logs = {}
        end
        
        DebugLog.print(result)
        
        DebugLog.inputText = ""
        DebugLog.hideKeyboard()
    end
end

function DebugLog.isTouchInside(x, y)
    if not DebugLog.visible then
        local b = DebugLog.button
        return x >= b.x and x <= b.x + b.w and y >= b.y and y <= b.y + b.h
    end
    return y <= love.graphics.getHeight() * 0.5
end

function DebugLog.getMaxScroll()
    local lineHeight = DebugLog.font:getHeight() + 2
    local consoleHeight = love.graphics.getHeight() * 0.5
    local visibleLines = math.floor((consoleHeight - 30) / lineHeight)
    return math.max(0, #DebugLog.logs - visibleLines + 2)
end

-- Отрисовка настроек
function DebugLog.drawSettings()
    local settingsWidth = 300
    local settingsHeight = math.min(400, love.graphics.getHeight() * 0.7) -- Ограничиваем максимальную высоту
    local x = love.graphics.getWidth() - settingsWidth - 10
    local y = 10
    
    -- Фон окна настроек
    love.graphics.setColor(0.1, 0.1, 0.2, 0.9)
    love.graphics.rectangle("fill", x, y, settingsWidth, settingsHeight)
    
    -- Заголовок
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Settings", x + 10, y + 10)
    
    -- Область для скроллинга
    local contentHeight = #DebugLog.sortedSettings * 30 + 20
    local scrollAreaHeight = settingsHeight - 40
    local scrollRatio = scrollAreaHeight / contentHeight
    
    -- Включаем ножницы для области с настройками
    love.graphics.setScissor(x, y + 40, settingsWidth, scrollAreaHeight)
    
    local itemY = y + 40 - (DebugLog.settingsScroll or 0)
    local lineHeight = 30
    local textX = x + 20
    local checkboxX = x + settingsWidth - 40
    
    -- Отрисовка всех настроек
    for _, name in ipairs(DebugLog.sortedSettings) do
        local value = DebugLog.settings[name]
        
        -- Название настройки
        love.graphics.print(name:gsub("^%l", string.upper), textX, itemY)
        
        -- Чекбокс
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.rectangle("fill", checkboxX, itemY - 3, 20, 20)
        
        if value then
            love.graphics.setColor(0, 1, 0)
            love.graphics.print("✓", checkboxX + 3, itemY - 3)
        end
        
        itemY = itemY + lineHeight
    end
    
    -- Выключаем ножницы
    love.graphics.setScissor()
    
    -- Полоса прокрутки (если контент не помещается)
    if scrollRatio < 1 then
        local scrollBarHeight = scrollAreaHeight * scrollRatio
        local scrollBarY = y + 40 + (DebugLog.settingsScroll or 0) * scrollRatio
        
        love.graphics.setColor(0.5, 0.5, 0.5, 0.7)
        love.graphics.rectangle("fill", x + settingsWidth - 10, scrollBarY, 8, scrollBarHeight)
    end
    
    love.graphics.setColor(1, 1, 1)
end

-- Обработка касаний настроек
function DebugLog.handleSettingsTouch(x, y)
    local settingsWidth = 300
    local settingsHeight = math.min(400, love.graphics.getHeight() * 0.7)
    local settingsX = love.graphics.getWidth() - settingsWidth - 10
    local settingsY = 10

    -- Проверяем, было ли касание внутри окна настроек
    if x < settingsX or x > settingsX + settingsWidth or
       y < settingsY or y > settingsY + settingsHeight then
        DebugLog.settingsVisible = false
        return
    end

    -- Область контента с учетом скролла
    local contentY = y - settingsY - 40 + (DebugLog.settingsScroll or 0)
    
    -- Обработка чекбоксов
    local itemHeight = 30
    local itemIndex = math.floor(contentY / itemHeight) + 1
    
    if itemIndex >= 1 and itemIndex <= #DebugLog.sortedSettings then
        local name = DebugLog.sortedSettings[itemIndex]
        DebugLog.settings[name] = not DebugLog.settings[name]
        DebugLog.print(name .. " set to " .. tostring(DebugLog.settings[name]))
    end
end

-- Обработка скролла настроек
function DebugLog.handleSettingsScroll(dx, dy)
    if not DebugLog.settingsVisible then return end
    
    local settingsHeight = math.min(400, love.graphics.getHeight() * 0.7)
    local contentHeight = #DebugLog.sortedSettings * 30 + 20
    local scrollAreaHeight = settingsHeight - 40
    
    DebugLog.settingsScroll = (DebugLog.settingsScroll or 0) - dy * 20
    DebugLog.settingsScroll = math.max(0, math.min(contentHeight - scrollAreaHeight, DebugLog.settingsScroll))
end



return DebugLog