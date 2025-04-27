local class = require("lib.middleclass")
local UIPopup = require("src.ui.UIPopup")
local UIScrollArea = require("src.ui.UIScrollArea")
local UIButton = require("src.ui.UIButton")
local UIPropertyItem = require("src.ui.UIPropertyItem")

local UIInspectorPopup = class("UIInspectorPopup", UIPopup)


function UIInspectorPopup:initialize(x, y, w, h, title, target)
    UIPopup.initialize(self, x, y, w, h, title)
    self.target = target or {}
    self.itemHeight = 20
    self.lineSpacing = 5
    self.indentSize = 15
    
    -- Инициализация стилей
    self.style = {
        bg = {0.12, 0.12, 0.15, 0.95},
        header = {0.2, 0.2, 0.3, 1},
        text = {1, 1, 1, 1},
        closeButton = {0.9, 0.2, 0.2, 1},
        propertyKey = {0.6, 0.8, 1, 1},
        propertyValue = {1, 1, 1, 1},
        scrollBar = {0.6, 0.6, 0.6, 0.8}
    }
    
    -- Инициализация компонентов
    self:initCloseButton()
    self:initScrollArea()
    self:populateScrollArea()
end

function UIInspectorPopup:initCloseButton()
    -- Кнопка закрытия теперь позиционируется относительно попапа
    self.closeButton = UIButton:new(
        0, 0, 25, 25, "×", function() self.visible = false end
    )
    self.closeButton.color = self.style.closeButton
    self.closeButton.textColor = self.style.text
    self:addChild(self.closeButton)
end

function UIInspectorPopup:initScrollArea()
    -- Скролл-область позиционируется относительно попапа
    self.scrollArea = UIScrollArea:new(
        5, 35, self.width - 10, self.height - 40
    )
    self.scrollArea.bgColor = {0.1, 0.1, 0.12, 1}
    self.scrollArea.scrollBarColor = self.style.scrollBar
    self:addChild(self.scrollArea)
end

function UIInspectorPopup:updateAbsolutePosition(parentX, parentY)
    parentX = parentX or 0
    parentY = parentY or 0
    
    -- Обновляем абсолютные координаты попапа
    self._absX = parentX + self.x
    self._absY = parentY + self.y
    
    -- Обновляем позицию кнопки закрытия (относительно попапа)
    self.closeButton.x = self.width - 30
    self.closeButton.y = 5
    self.closeButton:updateAbsolutePosition(self._absX, self._absY)
    
    -- Обновляем позицию скролл-области (относительно попапа)
    self.scrollArea:updateAbsolutePosition(self._absX, self._absY)
    
    -- Обновляем все дочерние элементы
    for _, child in ipairs(self.children) do
        if child ~= self.closeButton and child ~= self.scrollArea and child.updateAbsolutePosition then
            child:updateAbsolutePosition(self._absX, self._absY)
        end
    end
end

function UIInspectorPopup:draw()
    if not self.visible then return end
    
    love.graphics.push("all")
    love.graphics.translate(self.x, self.y)
    
    -- Фон попапа
    love.graphics.setColor(self.style.bg)
    love.graphics.rectangle("fill", 0, 0, self.width, self.height, 5)
    love.graphics.setColor(0.3, 0.3, 0.4, 1)
    love.graphics.rectangle("line", 0, 0, self.width, self.height, 5)
    
    -- Заголовок
    love.graphics.setColor(self.style.header)
    love.graphics.rectangle("fill", 0, 0, self.width, 30, 5, 5, 0, 0)
    love.graphics.setColor(self.style.text)
    love.graphics.print(self.title, 10, 8)
    
    love.graphics.pop()
    
    -- Отрисовка дочерних элементов (кнопка и скролл-область)
    -- Они отрисовываются в своих абсолютных координатах
    self.closeButton:draw()
    self.scrollArea:draw()
end


function UIInspectorPopup:populateScrollArea()
    self.scrollArea:clearControls()
    local yPos = 5  -- Небольшой отступ сверху в скролл-области
    
    local function addProperties(t, prefix, indent)
        for k, v in pairs(t) do
            if type(k) ~= "string" or not k:match("^__") then
                local fullKey = prefix and (prefix .. "." .. k) or k
                
                local propItem = UIPropertyItem:new(
                    5 + indent * self.indentSize,
                    yPos,
                    self.scrollArea.width - 10,
                    self.itemHeight,
                    k,  -- Отображаем только текущий ключ, а не полный путь
                    v,
                    indent,
                    self.style
                )
                
                self.scrollArea:addControl(propItem)
                yPos = yPos + self.itemHeight + self.lineSpacing
                
                -- Рекурсивно добавляем вложенные свойства
                if type(v) == "table" and not getmetatable(v) then
                    addProperties(v, fullKey, indent + 1)
                end
            end
        end
    end
    
    addProperties(self.target, nil, 0)
    self.scrollArea:updateContentHeight()
end

function UIInspectorPopup:update(dt)
    if not self.visible then return end
    self.scrollArea:update(dt)
end

-- Обработчики событий
function UIInspectorPopup:touchpressed(id, x, y)
    if not self.visible then return false end
    
    -- Проверяем кнопку закрытия
    if self.closeButton:isInside(x, y) then
        return self.closeButton:touchpressed(id, x, y)
    end
    
    -- Проверяем заголовок для перетаскивания
    local localX, localY = x - self.x, y - self.y
    if localY <= 30 then
        return UIPopup.touchpressed(self, id, x, y)
    end
    
    -- Передаем событие в скролл-область
    if self.scrollArea:isInside(localX, localY) then
        return self.scrollArea:touchpressed(id, localX - self.scrollArea.x, localY - self.scrollArea.y)
    end
    
    return true
end

function UIInspectorPopup:touchmoved(id, x, y, dx, dy)
    if not self.visible then return false end
    
    if self.dragging then
        return UIPopup.touchmoved(self, id, x, y, dx, dy)
    end
    
    local localX, localY = x - self.x, y - self.y
    if self.scrollArea:isInside(localX, localY) then
        return self.scrollArea:touchmoved(id, localX - self.scrollArea.x, localY - self.scrollArea.y, dx, dy)
    end
    
    return false
end

function UIInspectorPopup:touchreleased(id, x, y)
    if not self.visible then return false end
    
    self.closeButton:touchreleased(id, x, y)
    
    local localX, localY = x - self.x, y - self.y
    if self.scrollArea:isInside(localX, localY) then
        return self.scrollArea:touchreleased(id, localX - self.scrollArea.x, localY - self.scrollArea.y)
    end
    
    self.dragging = false
    return true
end

return UIInspectorPopup