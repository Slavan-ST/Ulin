

local class = require("lib.middleclass")

local UIElement = class("UIElement")

function UIElement:initialize(x, y, width, height)
    self.x = x or 0
    self.y = y or 0
    self.width = width or 100
    self.height = height or 50
    self.visible = true
    self.zIndex = 0
end

function UIElement:isInside(x, y)
    return x >= self.x and x <= self.x + self.width and
           y >= self.y and y <= self.y + self.height
end

function UIElement:update(dt) end
function UIElement:draw() end
function UIElement:touchpressed(id, x, y) end
function UIElement:touchmoved(id, x, y) end
function UIElement:touchreleased(id, x, y) end

return UIElement
