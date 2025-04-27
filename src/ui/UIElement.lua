local class = require("lib.middleclass")

local UIElement = class("UIElement")

function UIElement:initialize(x, y, width, height)
    -- Базовые свойства
    self.x = x or 0
    self.y = y or 0
    self.width = width or 100
    self.height = height or 50
    self.visible = true
    
    -- Иерархия элементов
    self.children = {}
    self.parent = nil
    
    -- Абсолютные координаты
    self._absX = x or 0
    self._absY = y or 0
    
    -- Состояние элемента
    self.draggable = false
    self.dragging = false
    self.dragStartX = 0
    self.dragStartY = 0
    self.active = false
    self.hovered = false
end

-- Основные методы ----------------------------------------------------
function UIElement:update(dt)
    for _, child in ipairs(self.children) do
        if child.update then child:update(dt) end
    end
end

function UIElement:draw()
    if not self.visible then return end
    
    love.graphics.push("all")
    love.graphics.translate(self.x, self.y)
    
    for _, child in ipairs(self.children) do
        if child.draw then child:draw() end
    end
    
    love.graphics.pop()
end

-- Обработка ввода ---------------------------------------------------
function UIElement:touchpressed(id, x, y)
    if not self:isInside(x, y) then return false end
    
    if self.draggable then
        self.dragging = true
        self.dragStartX = x - self._absX
        self.dragStartY = y - self._absY
        return true
    end
    
    return self:propagateToChildren("touchpressed", id, x, y)
end

function UIElement:touchmoved(id, x, y, dx, dy)
    if self.dragging then
        self.x = x - self.dragStartX - (self.parent and self.parent._absX or 0)
        self.y = y - self.dragStartY - (self.parent and self.parent._absY or 0)
        self:updateAbsolutePosition()
        return true
    end
    
    return self:propagateToChildren("touchmoved", id, x, y, dx, dy)
end

function UIElement:touchreleased(id, x, y)
    self.dragging = false
    return self:propagateToChildren("touchreleased", id, x, y)
end

-- Управление иерархией ----------------------------------------------
function UIElement:addChild(child)
    if not self.children then self.children = {} end
    child.parent = self
    table.insert(self.children, child)
    child:updateAbsolutePosition(self._absX, self._absY)
    return true
end

function UIElement:removeChild(child)
    for i, c in ipairs(self.children) do
        if c == child then
            child.parent = nil
            table.remove(self.children, i)
            return true
        end
    end
    return false
end

-- Координаты --------------------------------------------------------
function UIElement:updateAbsolutePosition(parentX, parentY)
    parentX = parentX or 0
    parentY = parentY or 0
    
    self._absX = parentX + self.x
    self._absY = parentY + self.y
    
    for _, child in ipairs(self.children) do
        if child.updateAbsolutePosition then
            child:updateAbsolutePosition(self._absX, self._absY)
        end
    end
end

function UIElement:isInside(x, y)
    return x >= self._absX and x <= self._absX + self.width and
           y >= self._absY and y <= self._absY + self.height
end

-- Утилиты -----------------------------------------------------------
function UIElement:propagateToChildren(methodName, ...)
    for i = #self.children, 1, -1 do
        local child = self.children[i]
        if child[methodName] and child[methodName](child, ...) then
            return true
        end
    end
    return false
end

function UIElement:withScissor(fn, padding)
    if not padding then
      padding = 0
    end
    
    love.graphics.push("all")
    love.graphics.setScissor(self._absX, self._absY, self.width - padding, self.height)
    fn()
    love.graphics.pop()
end

-- Состояние элемента ------------------------------------------------
function UIElement:setActive(active) self.active = active end
function UIElement:onHoverChanged(hovered) self.hovered = hovered end

return UIElement