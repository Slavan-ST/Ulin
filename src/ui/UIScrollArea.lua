local class = require("lib.middleclass")
local UIElement = require("src.ui.UIElement")

local UIScrollArea = class("UIScrollArea", UIElement)

function UIScrollArea:initialize(x, y, width, height)
    UIElement.initialize(self, x, y, width, height)
    self.scrollY = 0
    self.scrollSpeed = 20
    self.contentHeight = height
    self.controls = {} -- Элементы для скролла
    self._isScrolling = false
end

function UIScrollArea:draw()
    self:withScissor(function()
        love.graphics.push()
        love.graphics.translate(0, -self.scrollY)
        
        -- Отрисовка стандартных детей
        UIElement.draw(self)
        
        -- Отрисовка элементов controls
        for _, control in ipairs(self.controls) do
            love.graphics.push()
            love.graphics.translate(control.x, control.y)
            if control.draw then control:draw() end
            love.graphics.pop()
        end
        
        love.graphics.pop()
    end)
end

function UIScrollArea:touchpressed(id, x, y)
    local localX = x - self._absX
    local localY = y - self._absY + self.scrollY
    
    -- Проверяем клик по элементам
    for i = #self.controls, 1, -1 do
        local control = self.controls[i]
        if control and control.isInside and control:isInside(localX, localY) then
            if control.touchpressed then
                return control:touchpressed(id, localX, localY)
            end
        end
    end
    
    -- Начинаем скроллинг
    self._isScrolling = true
    return true
end

function UIScrollArea:touchmoved(id, x, y, dx, dy)
    if self._isScrolling then
        local newScrollY = self.scrollY - dy
        self.scrollY = math.max(0, math.min(newScrollY, self.contentHeight - self.height))
        return true
    end
    return false
end


function UIScrollArea:touchreleased(id, x, y)
    self._isScrolling = false
    return false
end

function UIScrollArea:updateContentHeight()
    local maxY = 0
    for _, control in ipairs(self.controls) do
        local bottom = control.y + control.height
        if bottom > maxY then maxY = bottom end
    end
    self.contentHeight = math.max(maxY, self.height)
end

return UIScrollArea