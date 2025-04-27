local class = require("lib.middleclass")
local UIElement = require("src.ui.UIElement")

local UIInputField = class("UIInputField", UIElement)

function UIInputField:initialize(x, y, width, height, placeholder)
    UIElement.initialize(self, x, y, width, height)
    self.text = ""
    self.placeholder = placeholder or ""
    self.active = false
    self.cursorPos = 1
    self.cursorVisible = true
    self.cursorBlinkTime = 0
    self.cursorBlinkInterval = 0.5
    self.textColor = {0, 0, 0, 1}
    self.placeholderColor = {0.5, 0.5, 0.5, 1}
    self.backgroundColor = {1, 1, 1, 1}
    self.activeBackgroundColor = {0.95, 0.95, 1, 1}
    self.borderColor = {0.7, 0.7, 0.7, 1}
    self.activeBorderColor = {0.4, 0.4, 0.8, 1}
    self.padding = 5
    self.font = love.graphics.newFont(12)
end

function UIInputField:draw()
    if not self.visible then return end
    
    -- Фон
    love.graphics.setColor(self.active and self.activeBackgroundColor or self.backgroundColor)
    love.graphics.rectangle("fill", self._absX, self._absY, self.width, self.height)
    
    -- Граница
    love.graphics.setColor(self.active and self.activeBorderColor or self.borderColor)
    love.graphics.rectangle("line", self._absX, self._absY, self.width, self.height)
    
    -- Текст
    love.graphics.setFont(self.font)
    local textToShow = self.text
    if textToShow == "" and not self.active then
        love.graphics.setColor(self.placeholderColor)
        textToShow = self.placeholder
    else
        love.graphics.setColor(self.textColor)
    end
    
    -- Обрезаем текст если он не помещается
    local textWidth = self.font:getWidth(textToShow)
    local drawX = self._absX + self.padding
    if textWidth > self.width - 2*self.padding then
        love.graphics.push("all")
        love.graphics.setScissor(self._absX + self.padding, self._absY, 
                               self.width - 2*self.padding, self.height)
    end
    
    love.graphics.print(textToShow, drawX, self._absY + (self.height - self.font:getHeight())/2)
    
    if textWidth > self.width - 2*self.padding then
        love.graphics.pop()
    end
    
    -- Курсор
    if self.active and self.cursorVisible then
        local cursorX = drawX
        if self.text ~= "" then
            local textBeforeCursor = self.text:sub(1, self.cursorPos-1)
            cursorX = cursorX + self.font:getWidth(textBeforeCursor)
        end
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.rectangle("fill", cursorX, self._absY + self.padding, 
                               1, self.height - 2*self.padding)
    end
end

function UIInputField:update(dt)
    if self.active then
        self.cursorBlinkTime = self.cursorBlinkTime + dt
        if self.cursorBlinkTime >= self.cursorBlinkInterval then
            self.cursorBlinkTime = 0
            self.cursorVisible = not self.cursorVisible
        end
    else
        self.cursorVisible = true
    end
end

function UIInputField:touchpressed(id, x, y)
    if not self:isInside(x, y) then 
        self.active = false
        love.keyboard.setTextInput(false)
        return false
    end
    
    self.active = true
    self.cursorVisible = true
    self.cursorBlinkTime = 0
    love.keyboard.setTextInput(true)
    
    -- Устанавливаем позицию курсора
    if self.text ~= "" then
        local localX = x - self._absX - self.padding
        for i = 1, #self.text do
            if self.font:getWidth(self.text:sub(1, i)) > localX then
                self.cursorPos = i
                return true
            end
        end
        self.cursorPos = #self.text + 1
    else
        self.cursorPos = 1
    end
    
    return true
end

function UIInputField:textinput(text)
    if not self.active then return false end
    
    self.text = self.text:sub(1, self.cursorPos-1) .. text .. self.text:sub(self.cursorPos)
    self.cursorPos = self.cursorPos + #text
    self.cursorVisible = true
    self.cursorBlinkTime = 0
    return true
end

function UIInputField:keypressed(key)
    if not self.active then return false end
    
    if key == "backspace" then
        if self.cursorPos > 1 then
            self.text = self.text:sub(1, self.cursorPos-2) .. self.text:sub(self.cursorPos)
            self.cursorPos = self.cursorPos - 1
        end
    elseif key == "delete" then
        if self.cursorPos <= #self.text then
            self.text = self.text:sub(1, self.cursorPos-1) .. self.text:sub(self.cursorPos+1)
        end
    elseif key == "left" then
        if self.cursorPos > 1 then
            self.cursorPos = self.cursorPos - 1
        end
    elseif key == "right" then
        if self.cursorPos <= #self.text then
            self.cursorPos = self.cursorPos + 1
        end
    elseif key == "home" then
        self.cursorPos = 1
    elseif key == "end" then
        self.cursorPos = #self.text + 1
    else
        return false
    end
    
    self.cursorVisible = true
    self.cursorBlinkTime = 0
    return true
end

return UIInputField