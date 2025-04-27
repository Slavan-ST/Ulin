-- Сначала создадим класс для элемента свойства
local class = require("lib.middleclass")
local UIElement = require("src.ui.UIElement")
local UIPropertyItem = class("UIPropertyItem")

function UIPropertyItem:initialize(x, y, width, height, key, value, indent, style)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.key = key
    self.value = value
    self.indent = indent
    self.style = style
end

function UIPropertyItem:draw()
    love.graphics.setColor(self.style.propertyKey)
    love.graphics.print(string.rep("  ", self.indent) .. tostring(self.key) .. ":", self.x, self.y)
    
    local valueX = self.x + 150
    love.graphics.setColor(self.style.propertyValue)
    love.graphics.print(tostring(self.value), valueX, self.y)
end

function UIPropertyItem:isInside(x, y)
    return x >= self.x and x <= self.x + self.width and
           y >= self.y and y <= self.y + self.height
end

return UIPropertyItem