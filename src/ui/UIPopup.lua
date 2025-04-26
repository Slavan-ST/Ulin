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
    self.draggable = true
    self.dragging = false
end



return UIPopup