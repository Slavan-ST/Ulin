-- src/ui/UIPopup.lua
local class = require("lib.middleclass")
local UIElement = require "src.ui.UIElement"
local UIPopup = class("UIPopup", UIElement)

function UIPopup:initialize(x, y, width, height, title)
    self.x = x or 100
    self.y = y or 100
    self.width = width or 300
    self.height = height or 400
    self.title = title or "Popup"
    self.visible = true
    self.zIndex = 100 -- Высокий индекс чтобы был поверх других элементов
    self.dragging = false
end

-- Базовые методы для переопределения
function UIPopup:update(dt) end
function UIPopup:draw() end
function UIPopup:touchpressed(id, x, y) end
function UIPopup:touchmoved(id, x, y, dx, dy) end
function UIPopup:touchreleased(id, x, y) end

-- Проверка попадания в элемент
function UIPopup:hitTest(x, y)
    return self.visible and x >= self.x and x <= self.x + self.width and
           y >= self.y and y <= self.y + self.height
end

return UIPopup