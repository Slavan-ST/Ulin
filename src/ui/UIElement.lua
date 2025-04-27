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
    
    -- Абсолютные координаты и z-индекс
    self._absX = x or 0
    self._absY = y or 0
    self.zIndex = 0
    self._calculatedZIndex = 0
    
    -- Состояние элемента
    self.draggable = false
    self.dragging = false
    self.dragStartX = 0
    self.dragStartY = 0
    self.active = false
    self.hovered = false
    
    -- Система событий
    self.eventListeners = {
        onClick = {},
        onHover = {},
        onDragStart = {},
        onDragEnd = {}
    }
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
        self:triggerEvent("onDragStart", x, y)
        return true
    end
    
    self:triggerEvent("onClick", x, y)
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
    if self.dragging then
        self.dragging = false
        self:triggerEvent("onDragEnd", x, y)
    end
    
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

-- Координаты и размеры ----------------------------------------------
function UIElement:updateAbsolutePosition(parentX, parentY)
    parentX = parentX or 0
    parentY = parentY or 0
    
    self._absX = parentX + self.x
    self._absY = parentY + self.y
    self._calculatedZIndex = (self.parent and self.parent._calculatedZIndex or 0) + self.zIndex
    
    for _, child in ipairs(self.children) do
        if child.updateAbsolutePosition then
            child:updateAbsolutePosition(self._absX, self._absY)
        end
    end
end

function UIElement:setPosition(x, y)
    self.x = x
    self.y = y
    self:updateAbsolutePosition()
    return self
end

function UIElement:setSize(width, height)
    self.width = width
    self.height = height
    self:updateAbsolutePosition()
    return self
end

function UIElement:isInside(x, y)
    return x >= self._absX and x <= self._absX + self.width and
           y >= self._absY and y <= self._absY + self.height
end

-- Система событий ---------------------------------------------------
function UIElement:on(eventName, callback)
    if not self.eventListeners[eventName] then
        self.eventListeners[eventName] = {}
    end
    table.insert(self.eventListeners[eventName], callback)
    return self
end

function UIElement:triggerEvent(eventName, ...)
    if not self.eventListeners then
        self.eventListeners = {
        onClick = {},
        onHover = {},
        onDragStart = {},
        onDragEnd = {}
    }
    end
    
    local listeners = self.eventListeners[eventName]
    if listeners then
        for _, callback in ipairs(listeners) do
            callback(self, ...)
        end
    end
end

-- Утилиты -----------------------------------------------------------
function UIElement:propagateToChildren(methodName, ...)
    -- Сортируем детей по zIndex перед обработкой
    local sortedChildren = {}
    for _, child in ipairs(self.children) do
        table.insert(sortedChildren, child)
    end
    
    table.sort(sortedChildren, function(a, b)
        return (a._calculatedZIndex or 0) > (b._calculatedZIndex or 0)
    end)
    
    -- Обрабатываем от верхнего к нижнему
    for _, child in ipairs(sortedChildren) do
        if child[methodName] and child[methodName](child, ...) then
            return true
        end
    end
    return false
end

function UIElement:withScissor(fn, paddingX, paddingY)
    paddingX = paddingX or 0
    paddingY = paddingY or 0
    
    love.graphics.push("all")
    love.graphics.intersectScissor(
        self._absX + paddingX,
        self._absY + paddingY,
        self.width - 2*paddingX,
        self.height - 2*paddingY
    )
    
    local success, err = pcall(fn)
    love.graphics.pop()
    
    if not success then error(err) end
end

-- Управление видимостью ---------------------------------------------
function UIElement:show()
    self.visible = true
    return self
end

function UIElement:hide()
    self.visible = false
    return self
end

function UIElement:toggleVisibility()
    self.visible = not self.visible
    return self
end

-- Состояние элемента ------------------------------------------------
function UIElement:setActive(active) 
    self.active = active
    return self
end

function UIElement:onHoverChanged(hovered) 
    self.hovered = hovered
    self:triggerEvent("onHover", hovered)
    return self
end

return UIElement