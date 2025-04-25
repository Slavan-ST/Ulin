-- UILabel.lua
local class = require("lib.middleclass")
local UIElement = require("src.ui.UIElement")

local UILabel = class("UILabel", UIElement)

function UILabel:initialize(x, y, text, font)
    UIElement.initialize(self, x, y, 0, 0)
    self.text = text or ""
    self.font = font or love.graphics.newFont(12)
end

function UILabel:draw()
    if not self.visible then return end
    love.graphics.setFont(self.font)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(self.text, self.x, self.y)
end

return UILabel
