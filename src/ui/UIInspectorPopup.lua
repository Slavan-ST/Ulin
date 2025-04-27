local class = require("lib.middleclass")
local UIPopup = require("src.ui.UIPopup")
local UIScrollArea = require("src.ui.UIScrollArea")
local UIButton = require("src.ui.UIButton")

local UIInspectorPopup = class("UIInspectorPopup", UIPopup)

function UIInspectorPopup:initialize(x, y, w, h, title, target, style)
    UIPopup.initialize(self, x, y, w, h, title)
    self.target = target
    self.style = style or {
        bg = {0.7, 0.7, 0.7, 0.9},
        header = {0.2, 0.2, 0.3, 1},
        text = {1, 1, 1, 1},
        closeButton = {0.9, 0.2, 0.2, 1}
    }
    
    self.font = love.graphics.newFont(12)
    self.itemHeight = 20
    self.zIndex = 1000
    self.draggable = true
    
    self:initCloseButton()
    self:initScrollArea()
    self:populateScrollArea()
end

function UIInspectorPopup:initCloseButton()
    self.closeButton = UIButton:new(
        self.width - 30, -- x (фиксированная позиция справа)
        5,              -- y (фиксированная позиция сверху)
        20,             -- width
        20,             -- height
        "×",
        function()
            require("src.ui.DebugConsole").printLog("bt close")
            self.visible = false 
        end
    )
    
    self.closeButton.color = self.style.closeButton
    self.closeButton.pressedColor = {1, 0.3, 0.3, 1}
    self.closeButton.textColor = self.style.text
    self.closeButton.zIndex = self.zIndex + 1
    self.closeButton.draggable = false
    
    self:addChild(self.closeButton)
end

function UIInspectorPopup:initScrollArea()
    -- Устанавливаем начало области прокрутки ниже заголовка (на 35 пикселей)
    self.scrollArea = UIScrollArea:new(
        5,  -- x
        35, -- y (ниже заголовка)
        self.width - 10, -- width
        self.height - 40 -- height
    )
    self.scrollArea.parent = self
    self.scrollArea.zIndex = self.zIndex
    self.scrollArea.draggable = false
    self:addChild(self.scrollArea)
end

function UIInspectorPopup:draw()
    if not self.visible then return end
    
    love.graphics.push("all")
    love.graphics.translate(self.x, self.y)
    
    -- Фон
    love.graphics.setColor(self.style.bg)
    love.graphics.rectangle("fill", 0, 0, self.width, self.height, 5)
    
    -- Заголовок
    self:drawHeader()
    
    -- Отрисовка скролл-области ниже заголовка
    love.graphics.setColor(0.15, 0.15, 0.2, 0.8)
    love.graphics.rectangle("fill", 
        self.scrollArea.x, 
        self.scrollArea.y, 
        self.scrollArea.width, 
        self.scrollArea.height
    )
    
    -- Отображаем элементы внутри области прокрутки
    for _, item in ipairs(self.scrollArea.controls) do
        if item.draw then
            item:draw()
        end
    end
    
    -- Кнопка закрытия (рисуется последней, чтобы быть поверх всего)
    love.graphics.pop()
    self.closeButton:draw()
    self.scrollArea:draw()
end

function UIInspectorPopup:updateAbsolutePosition(parentX, parentY)
    parentX = parentX or 0
    parentY = parentY or 0
    
    self._absX = parentX + self.x
    self._absY = parentY + self.y
    
    -- Обновляем позицию кнопки закрытия
    if self.closeButton then
        self.closeButton.x = self.width - 30
        self.closeButton.y = 5
        self.closeButton:updateAbsolutePosition(self._absX, self._absY)
    end
    
    -- Обновляем позицию скролл-области
    if self.scrollArea then
        self.scrollArea:updateAbsolutePosition(self._absX, self._absY)
    end
    
    -- Обновляем остальные дочерние элементы
    for _, child in ipairs(self.children) do
        if child ~= self.closeButton and child ~= self.scrollArea and child.updateAbsolutePosition then
            child:updateAbsolutePosition(self._absX, self._absY + 35)
        end
    end
end

function UIInspectorPopup:populateScrollArea()
    self.scrollArea.controls = {}
    local yPos = 0
    
    local function addProperties(t, prefix, indent)
        for k, v in pairs(t) do
            if type(k) ~= "string" or not k:match("^__") then
                local fullKey = prefix and (prefix .. "." .. k) or k
                self:addPropertyItem(fullKey, v, yPos, indent)
                yPos = yPos + self.itemHeight
                
                if type(v) == "table" and not getmetatable(v) then
                    addProperties(v, fullKey, indent + 1)
                end
            end
        end
    end
    
    addProperties(self.target, nil, 0)
    
    -- После добавления всех элементов обновляем высоту контента
    self.scrollArea:updateContentHeight()
end

function UIInspectorPopup:addPropertyItem(key, value, yPos, indent)
    local propItem = {
        x = 5 + indent * 15,
        y = yPos,
        width = self.scrollArea.width - 10 - indent * 15,
        height = self.itemHeight,
        draw = function(self)
            love.graphics.setColor(self.parent.parent.style.text)
            local text = string.rep("  ", indent) .. tostring(key) .. ": " .. tostring(value)
            love.graphics.print(text, self.x, self.y + self.parent.scrollY)
        end,
        isInside = function(self, x, y)
            local scrollY = self.parent.scrollY or 0
            return x >= self.x and x <= self.x + self.width and
                   y >= self.y - scrollY and y <= self.y + self.height - scrollY
        end,
        parent = self.scrollArea,
        draggable = false
    }
    
    self.scrollArea:addControl(propItem)
end

function UIInspectorPopup:drawHeader()
    love.graphics.setColor(self.style.header)
    love.graphics.rectangle("fill", 0, 0, self.width, 30)
    
    love.graphics.setColor(self.style.text)
    love.graphics.setFont(self.font)
    love.graphics.print(self.title, 10, 5)
end

function UIInspectorPopup:draw()
    if not self.visible then return end
    
    love.graphics.push("all")
    love.graphics.translate(self.x, self.y)
    
    -- Фон
    love.graphics.setColor(self.style.bg)
    love.graphics.rectangle("fill", 0, 0, self.width, self.height, 5)
    
    -- Заголовок
    self:drawHeader()
    
    -- Отрисовка скролл-области
    
    
    -- Кнопка закрытия (рисуется последней, чтобы быть поверх всего)
    love.graphics.pop()
    self.closeButton:draw()
    self.scrollArea:draw()
end

function UIInspectorPopup:touchpressed(id, x, y)
    if not self.visible then return false end
    
    -- Проверяем попадание в попап
    if not self:isInside(x, y) then return false end
    
    local localX, localY = x - self.x, y - self.y
    
    -- 1. Сначала проверяем кнопку закрытия
    if self.closeButton:isInside(x, y) then
        return self.closeButton:touchpressed(id, x, y)
    end
    
    -- 2. Проверяем заголовок для перетаскивания
    if localY <= 30 then
        return UIPopup.touchpressed(self, id, x, y)
    end
    
    -- 3. Проверяем скролл-область (не мешаем другим действиям)
    if not self.dragging and self.scrollArea:isInside(localX, localY) then
        local scrollX = localX - self.scrollArea.x
        local scrollY = localY - self.scrollArea.y + (self.scrollArea.scrollY or 0)
        return self.scrollArea:touchpressed(id, scrollX, scrollY)
    end
    
    return true
end

function UIInspectorPopup:touchmoved(id, x, y, dx, dy)
    if not self.visible then return false end
    
    -- Если начали перетаскивание - обрабатываем только его
    if self.dragging then
        return UIPopup.touchmoved(self, id, x, y, dx, dy)
    end
    
    -- Обрабатываем скроллинг
    local localX, localY = x - self.x, y - self.y
    if self.scrollArea:isInside(localX, localY) then
        local scrollX = localX - self.scrollArea.x
        local scrollY = localY - self.scrollArea.y + (self.scrollArea.scrollY or 0)
        return self.scrollArea:touchmoved(id, scrollX, scrollY, dx, dy)
    end
    
    return false
end

function UIInspectorPopup:touchreleased(id, x, y)
    if not self.visible then return false end
    
    local localX, localY = x - self.x, y - self.y
    
    -- Обрабатываем кнопку закрытия
    self.closeButton:touchreleased(id, x, y)
    
    -- Обрабатываем скролл-область
    if self.scrollArea:isInside(localX, localY) then
        local scrollX = localX - self.scrollArea.x
        local scrollY = localY - self.scrollArea.y + (self.scrollArea.scrollY or 0)
        return self.scrollArea:touchreleased(id, scrollX, scrollY)
    end
    
    -- Завершаем перетаскивание
    self.dragging = false
    return true
end

function UIInspectorPopup:update(dt)
    if not self.visible then return end
    self.scrollArea:update(dt)
end

return UIInspectorPopup