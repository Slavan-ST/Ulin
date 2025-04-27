local class = require("lib.middleclass")
local UIElement = require("src.ui.UIElement")

local UILoader = class("UILoader", UIElement)

function UILoader:initialize(x, y, width, height)
    UIElement.initialize(self, x, y, width, height)
    self.progress = 0
    self.loadingColor = {0.2, 0.6, 1, 1}
    self.backgroundColor = {0.9, 0.9, 0.9, 1}
    self.borderColor = {0.7, 0.7, 0.7, 1}
    self.textColor = {0, 0, 0, 1}
    self.showPercentage = true
    self.animationTime = 0
end

function UILoader:draw()
    if not self.visible then return end
    
    -- Фон
    love.graphics.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", self._absX, self._absY, self.width, self.height)
    
    -- Граница
    love.graphics.setColor(self.borderColor)
    love.graphics.rectangle("line", self._absX, self._absY, self.width, self.height)
    
    -- Прогресс
    local progressWidth = math.max(5, self.width * self.progress)
    love.graphics.setColor(self.loadingColor)
    love.graphics.rectangle("fill", self._absX, self._absY, progressWidth, self.height)
    
    -- Анимация (если progress = 0)
    if self.progress == 0 then
        local animWidth = self.width * 0.3
        local animPos = (self.animationTime * 2 % (self.width + animWidth)) - animWidth
        love.graphics.setColor(1, 1, 1, 0.5)
        love.graphics.rectangle("fill", self._absX + animPos, self._absY, animWidth, self.height)
    end
    
    -- Текст с процентом
    if self.showPercentage then
        love.graphics.setColor(self.textColor)
        local text = string.format("%d%%", math.floor(self.progress * 100))
        local font = love.graphics.getFont()
        local textWidth = font:getWidth(text)
        local textHeight = font:getHeight()
        love.graphics.print(text, 
            self._absX + (self.width - textWidth)/2, 
            self._absY + (self.height - textHeight)/2)
    end
end

function UILoader:update(dt)
    self.animationTime = self.animationTime + dt
end

function UILoader:setProgress(progress)
    self.progress = math.min(1, math.max(0, progress))
    return self
end

function UILoader:getProgress()
    return self.progress
end

function UILoader:setShowPercentage(show)
    self.showPercentage = show
    return self
end

return UILoader