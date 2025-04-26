local class = require("lib.middleclass")
local UIElement = require("src.ui.UIElement")

local UIScrollArea = class("UIScrollArea", UIElement)

function UIScrollArea:initialize(x, y, width, height)
    UIElement.initialize(self, x, y, width, height)
    self.scrollY = 0
    self.scrollSpeed = 20
    self.contentHeight = height
end

function UIScrollArea:draw()
    self:withScissor(function()
        love.graphics.push()
        love.graphics.translate(0, -self.scrollY)
        UIElement.draw(self)
        love.graphics.pop()
    end)
end

function UIScrollArea:touchmoved(id, x, y, dx, dy)
    if not self.dragging then
        self.scrollY = math.max(0, math.min(
            self.scrollY - dy, 
            self.contentHeight - self.height
        ))
        return true
    end
    return UIElement.touchmoved(self, id, x, y, dx, dy)
end

function UIScrollArea:updateContentHeight()
    local maxY = 0
    for _, child in ipairs(self.children) do
        local bottom = child.y + (child.height or 0)
        if bottom > maxY then maxY = bottom end
    end
    self.contentHeight = math.max(maxY, self.height)
end

return UIScrollArea