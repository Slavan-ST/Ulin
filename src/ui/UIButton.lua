-- UIButton.lua
local class = require("lib.middleclass")
local UIElement = require("src.ui.UIElement")

local UIButton = class("UIButton", UIElement)

function UIButton:initialize(x, y, width, height, label, onClick)
    UIElement.initialize(self, x, y, width, height)
    self.label = label or "Button"
    self.onClick = onClick or function() end
    self.color = {0.3, 0.6, 0.8}
    self.pressedColor = {0.8, 0.3, 0.3}
    self.currentColor = self.color
    self.textColor = {1, 1, 1}
end

function UIButton:draw()
    if not self.visible then return end
    
    -- Рисуем кнопку
    love.graphics.setColor(self.currentColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 5)
    
    -- Рисуем текст
    love.graphics.setColor(self.textColor)
    local font = love.graphics.getFont()
    local textHeight = font and font:getHeight() or 12
    love.graphics.printf(self.label, self.x, self.y + (self.height - textHeight)/2, self.width, "center")
end

function UIButton:touchpressed(id, x, y)
    if self:isInside(x, y) then
        self.currentColor = self.pressedColor
        return true
    end
    return false
end

function UIButton:touchreleased(id, x, y)
    self.currentColor = self.color
    if self:isInside(x, y) and self.onClick then
        self.onClick()
    end
end

return UIButton