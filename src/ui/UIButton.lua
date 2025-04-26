local class = require("lib.middleclass")
local UIElement = require("src.ui.UIElement")

local UIButton = class("UIButton", UIElement)

function UIButton:initialize(x, y, width, height, label, onClick)
    UIElement.initialize(self, x, y, width, height)
    self.label = label or "Button"
    self.onClick = onClick or function() end
    self.color = {0.3, 0.6, 0.8, 1}       -- Добавлен альфа-канал
    self.pressedColor = {0.8, 0.3, 0.3, 1} -- Добавлен альфа-канал
    self.currentColor = self.color
    self.textColor = {1, 1, 1, 1}         -- Добавлен альфа-канал
    self.isPressed = false
end

function UIButton:draw()
    if not self.visible then return end
    
    -- Рисуем прямоугольник кнопки
    love.graphics.setColor(self.currentColor)
    love.graphics.rectangle("fill", self._absX, self._absY, self.width, self.height, 5)
    
    -- Рисуем текст
    love.graphics.setColor(self.textColor)
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(self.label)
    local textHeight = font:getHeight()
    love.graphics.print(
        self.label,
        self._absX + (self.width - textWidth)/2,
        self._absY + (self.height - textHeight)/2
    )
end

function UIButton:touchpressed(id, x, y)
    if not self:isInside(x, y) then return false end
    
    self.isPressed = true
    self.currentColor = self.pressedColor
    return true  -- Возвращаем true, чтобы показать, что событие обработано
end

function UIButton:touchmoved(id, x, y, dx, dy)
    if self.isPressed then
        -- Если кнопка была нажата, проверяем остались ли мы внутри
        if not self:isInside(x, y) then
            self.isPressed = false
            self.currentColor = self.color
        end
    end
    return true
end

function UIButton:touchreleased(id, x, y)
    if self.isPressed then
        self.isPressed = false
        self.currentColor = self.color
        
        if self:isInside(x, y) then
            self.onClick()
        end
    end
    return true
end

return UIButton