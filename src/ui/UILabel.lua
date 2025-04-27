local class = require("lib.middleclass")
local UIElement = require("src.ui.UIElement")

local UILabel = class("UILabel", UIElement)

function UILabel:initialize(x, y, text, font, color)
    UIElement.initialize(self, x, y, 0, 0)
    self.text = text or ""
    self.font = font or love.graphics.newFont(12)
    self.color = color or {1, 1, 1, 1}
    self.align = "left" -- left, center, right
    self:updateSize()
end

function UILabel:setText(text)
    self.text = text or ""
    self:updateSize()
end

function UILabel:updateSize()
    if self.text == "" then
        self.width = 0
        self.height = self.font:getHeight()
    else
        self.width = self.font:getWidth(self.text)
        self.height = self.font:getHeight()
    end
end

function UILabel:draw()
    if not self.visible then return end
    
    love.graphics.setFont(self.font)
    love.graphics.setColor(self.color)
    
    local x = self._absX
    if self.align == "center" then
        x = self._absX - self.width/2
    elseif self.align == "right" then
        x = self._absX - self.width
    end
    
    love.graphics.print(self.text, x, self._absY)
end

return UILabel