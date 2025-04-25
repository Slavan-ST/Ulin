local class = require("lib.middleclass")
local UIElement = require("src.ui.UIElement")

local UIScrollArea = class("UIScrollArea", UIElement)

function UIScrollArea:initialize(x, y, width, height)
    UIElement.initialize(self, x, y, width, height)
    self.controls = {}
    self.scrollY = 0
    self.scrollSpeed = 20
    self.contentHeight = 0
    self._absX = x  -- Абсолютные координаты
    self._absY = y
end

function UIScrollArea:addControl(control)
    control.parent = self  -- Устанавливаем себя как родителя
    table.insert(self.controls, control)
    self:updateContentHeight()
end

function UIScrollArea:updateContentHeight()
    local maxY = 0
    for _, ctrl in ipairs(self.controls) do
        local bottom = ctrl.y + (ctrl.height or 0)
        if bottom > maxY then
            maxY = bottom
        end
    end
    self.contentHeight = math.max(maxY, self.height)
end

function UIScrollArea:updateAbsolutePosition(parentX, parentY)
    self._absX = parentX + self.x
    self._absY = parentY + self.y
    -- Обновляем позиции всех дочерних элементов
    for _, control in ipairs(self.controls) do
        if control.updateAbsolutePosition then
            control:updateAbsolutePosition(self._absX, self._absY)
        end
    end
end

function UIScrollArea:draw()
    -- Сохраняем текущее состояние отрисовки
    love.graphics.push("all")
    
    -- Устанавливаем область отсечения
    love.graphics.setScissor(self._absX, self._absY, self.width, self.height)
    
    -- Отрисовываем содержимое с учетом скролла
    love.graphics.push()
    love.graphics.translate(self._absX, self._absY - self.scrollY)
    
    for _, ctrl in ipairs(self.controls) do
        if ctrl.draw then
            ctrl:draw()
        end
    end
    
    love.graphics.pop()
    
    -- Восстанавливаем состояние
    love.graphics.pop()
end

function UIScrollArea:touchpressed(id, x, y)
    if not self:isInside(x, y) then return false end

    -- Преобразуем координаты относительно скролла
    local localX = x - self._absX
    local localY = y - self._absY + self.scrollY
    
    -- Обрабатываем от верхнего к нижнему (по zIndex)
    for i = #self.controls, 1, -1 do
        local ctrl = self.controls[i]
        if ctrl.isInside and ctrl:isInside(localX, localY) then
            if ctrl.touchpressed and ctrl:touchpressed(id, localX, localY) then
                return true
            end
        end
    end
    
    return true
end

function UIScrollArea:touchmoved(id, x, y, dx, dy)
    if not self:isInside(x, y) then return false end

    -- Обработка скролла
    self.scrollY = math.max(0, math.min(self.scrollY - dy, self.contentHeight - self.height))
    return true
end

function UIScrollArea:isInside(x, y)
    return x >= self._absX and x <= self._absX + self.width and
           y >= self._absY and y <= self._absY + self.height
end

return UIScrollArea