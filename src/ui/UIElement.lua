local class = require("lib.middleclass")

local UIElement = class("UIElement")

function UIElement:initialize(x, y, width, height)
    -- Базовые свойства
    self.x = x or 0
    self.y = y or 0
    self.width = width or 100
    self.height = height or 50
    self.visible = true
    self.zIndex = 0
    
    -- Иерархия элементов
    self.children = {}  -- Гарантированная инициализация
    self.parent = nil
    
    -- Абсолютные координаты
    self._absX = x or 0
    self._absY = y or 0
    
    -- Перетаскивание
    self.draggable = false
    self.dragging = false
    self.dragStartX = 0
    self.dragStartY = 0
    
    -- Состояние
    self.active = false
    self.hovered = false
end

-- Основные методы =====================================================

function UIElement:update(dt)
    if not self.children then return end
    
    for _, child in ipairs(self.children) do
        if child and child.update then 
            child:update(dt) 
        end
    end
end

function UIElement:draw()
    if not self.visible or not self.children then return end
    
    love.graphics.push("all")
    love.graphics.translate(self.x, self.y)
    
    for _, child in ipairs(self.children) do
        if child and child.draw then 
            child:draw() 
        end
    end
    
    love.graphics.pop()
end

-- Обработка ввода ====================================================

function UIElement:touchpressed(id, x, y)
    if not self:isInside(x, y) then return false end
    
    -- Обработка перетаскивания
    if self.draggable then
        self.dragging = true
        self.dragStartX = x - self._absX
        self.dragStartY = y - self._absY
        return true
    end
    
    -- Обработка детей (сверху вниз по zIndex)
    if self.children then
        for i = #self.children, 1, -1 do
            local child = self.children[i]
            if child and child.touchpressed and child:touchpressed(id, x, y) then
                return true
            end
        end
    end
    
    return false
end

function UIElement:touchmoved(id, x, y, dx, dy)
    -- Перетаскивание элемента
    if self.dragging and self.draggable then
        self.x = x - self.dragStartX - (self.parent and self.parent._absX or 0)
        self.y = y - self.dragStartY - (self.parent and self.parent._absY or 0)
        self:updateAbsolutePosition()
        return true
    end
    
    -- Передача события детям
    if self.children then
        for i = #self.children, 1, -1 do
            local child = self.children[i]
            if child and child.touchmoved and child:touchmoved(id, x, y, dx, dy) then
                return true
            end
        end
    end
    
    return false
end

function UIElement:touchreleased(id, x, y)
    self.dragging = false
    
    if self.children then
        for i = #self.children, 1, -1 do
            local child = self.children[i]
            if child and child.touchreleased and child:touchreleased(id, x, y) then
                return true
            end
        end
    end
    
    return false
end

-- Управление иерархией ===============================================

function UIElement:addChild(child)
    if not child then return false end
    
    -- Гарантируем инициализацию
    self.children = self.children or {}
    
    -- Устанавливаем связь
    child.parent = self
    table.insert(self.children, child)
    
    -- Обновляем zIndex и позицию
    self:sortChildren()
    child:updateAbsolutePosition(self._absX, self._absY)
    
    return true
end

function UIElement:removeChild(child)
    if not child or not self.children then return false end
    
    for i, c in ipairs(self.children) do
        if c == child then
            child.parent = nil
            table.remove(self.children, i)
            return true
        end
    end
    
    return false
end

function UIElement:sortChildren()
    if not self.children then return end
    
    table.sort(self.children, function(a, b)
        return (a.zIndex or 0) < (b.zIndex or 0)
    end)
end

-- Координаты и трансформации =========================================

function UIElement:updateAbsolutePosition(parentX, parentY)
    parentX = parentX or 0
    parentY = parentY or 0
    
    self._absX = parentX + self.x
    self._absY = parentY + self.y
    
    -- Рекурсивное обновление детей
    if self.children then
        for _, child in ipairs(self.children) do
            if child and child.updateAbsolutePosition then
                child:updateAbsolutePosition(self._absX, self._absY)
            end
        end
    end
end

function UIElement:isInside(x, y)
    return self.visible and  x >= self._absX and x <= self._absX + self.width and
           y >= self._absY and y <= self._absY + self.height
end

-- Утилиты ============================================================

function UIElement:withScissor(fn)
    if not fn then return end
    
    love.graphics.push("all")
    love.graphics.setScissor(self._absX, self._absY, self.width, self.height)
    fn()
    love.graphics.pop()
end

-- Состояние элемента =================================================

function UIElement:setActive(active)
    self.active = active
end

function UIElement:onHoverChanged(hovered)
    self.hovered = hovered
end

return UIElement