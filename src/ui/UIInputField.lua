-- UIInputField.lua
local class = require("lib.middleclass")
local UIElement = require("src.ui.UIElement")

local UIInputField = class("UIInputField", UIElement)

function UIInputField:initialize(x, y, width, height)
    UIElement.initialize(self, x, y, width, height)
    self.text = ""
    self.active = false
end

function UIInputField:draw()
    if not self.visible then return end
    love.graphics.setColor(self.active and {0.4, 0.4, 0.5} or {0.2, 0.2, 0.2})
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(self.text, self.x + 5, self.y + 5)
end

function UIInputField:touchpressed(id, x, y)
    self.active = self:isInside(x, y)
    love.keyboard.setTextInput(self.active)
end

function UIInputField:textinput(t)
    if self.active then
        self.text = self.text .. t
    end
end

function UIInputField:keypressed(key)
    if self.active and key == "backspace" then
        self.text = self.text:sub(1, -2)
    end
end

return UIInputField