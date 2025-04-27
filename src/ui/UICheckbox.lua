local class = require("lib.middleclass")
local UIElement = require("src.ui.UIElement")

local UICheckbox = class("UICheckbox", UIElement)

function UICheckbox:initialize(x, y, size, checked, onChange)
    UIElement.initialize(self, x, y, size, size)
    self.checked = checked or false
    self.onChange = onChange or function() end
    self.color = {0.8, 0.8, 0.8, 1}
    self.checkedColor = {0.2, 0.6, 1, 1}
    self.borderColor = {0.5, 0.5, 0.5, 1}
end

function UICheckbox:draw()
    if not self.visible then return end
    
    -- Фон
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", self._absX, self._absY, self.width, self.height)
    
    -- Граница
    love.graphics.setColor(self.borderColor)
    love.graphics.rectangle("line", self._absX, self._absY, self.width, self.height)
    
    -- Галочка
    if self.checked then
        love.graphics.setColor(self.checkedColor)
        love.graphics.setLineWidth(2)
        love.graphics.line(
            self._absX + 3, self._absY + self.height/2,
            self._absX + self.width/2 - 2, self._absY + self.height - 3,
            self._absX + self.width - 3, self._absY + 3
        )
        love.graphics.setLineWidth(1)
    end
end

function UICheckbox:touchpressed(id, x, y)
    if not self:isInside(x, y) then return false end
    
    self.checked = not self.checked
    self.onChange(self.checked)
    return true
end

function UICheckbox:setChecked(checked)
    self.checked = checked
    return self
end

function UICheckbox:isChecked()
    return self.checked
end

return UICheckbox