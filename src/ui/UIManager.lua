local class = require("lib.middleclass")
local UIElement = require("src.ui.UIElement")

local UIManager = class("UIManager", UIElement)

function UIManager:initialize()
    UIElement.initialize(self, 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- Состояние менеджера
    self.blockInput = false
    self.activeInputElement = nil
    self.focusedElement = nil
    self.hoveredElement = nil
    self.draggedElement = nil
    
    -- Элементы с управлением zIndex
    self._elements = {}
    self._nextZIndex = 1
    self._defaultZIndex = 1000
end

-- Управление элементами ---------------------------------------------
function UIManager:add(element, zIndex)
    if not element then return end
    
    -- Устанавливаем zIndex (если не указан, используем автоинкремент)
    element._zIndex = zIndex or self._nextZIndex
    self._nextZIndex = self._nextZIndex + 1
    
    -- Добавляем в оба списка
    self:addChild(element)
    table.insert(self._elements, element)
    
    -- Сортируем
    self:sortElements()
    return element
end

function UIManager:remove(element)
    if not element then return end
    
    for i, e in ipairs(self._elements) do
        if e == element then
            table.remove(self._elements, i)
            self:removeChild(element)
            self:clearElementReferences(element)
            break
        end
    end
end

function UIManager:clearElementReferences(element)
    if self.focusedElement == element then self.focusedElement = nil end
    if self.activeInputElement == element then self:setActiveInput(nil) end
    if self.hoveredElement == element then self:setHoveredElement(nil) end
    if self.draggedElement == element then self.draggedElement = nil end
end

-- Управление zIndex -------------------------------------------------
function UIManager:sortElements()
    table.sort(self._elements, function(a, b)
        return (a._zIndex or 0) < (b._zIndex or 0)
    end)
end

function UIManager:setZIndex(element, zIndex)
    if not element then return end
    element._zIndex = zIndex
    self:sortElements()
end

function UIManager:bringToFront(element)
    if not element then return end
    
    local max = 0
    for _, e in ipairs(self._elements) do
        if e ~= element and e._zIndex and e._zIndex > max then
            max = e._zIndex
        end
    end
    
    element._zIndex = max + 1
    self:sortElements()
end

function UIManager:sendToBack(element)
    if not element then return end
    
    local min = math.huge
    for _, e in ipairs(self._elements) do
        if e ~= element and e._zIndex and e._zIndex < min then
            min = e._zIndex
        end
    end
    
    element._zIndex = (min or 1) - 1
    self:sortElements()
end

-- Управление вводом -------------------------------------------------
function UIManager:setActiveInput(element)
    if self.activeInputElement then
        self.activeInputElement:setActive(false)
    end
    
    self.activeInputElement = element
    
    if element then
        element:setActive(true)
        self:bringToFront(element)
        love.keyboard.setTextInput(true)
    else
        love.keyboard.setTextInput(false)
    end
end

function UIManager:setHoveredElement(element)
    if self.hoveredElement == element then return end
    
    if self.hoveredElement and self.hoveredElement.onHoverChanged then
        self.hoveredElement:onHoverChanged(false)
    end
    
    self.hoveredElement = element
    
    if element and element.onHoverChanged then
        element:onHoverChanged(true)
    end
end

-- Обработчики событий -----------------------------------------------
function UIManager:touchpressed(id, x, y)
    if self.blockInput then return false end
    
    -- Снимаем фокус если кликнули мимо активного элемента
    if self.activeInputElement and not self.activeInputElement:isInside(x, y) then
        self:setActiveInput(nil)
    end

    -- Обработка сверху вниз (от элементов с большим zIndex)
    for i = #self._elements, 1, -1 do
        local element = self._elements[i]
        if element and element.visible and element:isInside(x, y) and element.touchpressed then
            if element:touchpressed(id, x, y) then
                self.focusedElement = element
                if element.draggable then
                    self.draggedElement = element
                    self:bringToFront(element)
                end
                return true
            end
        end
    end
    
    return false
end

function UIManager:touchmoved(id, x, y, dx, dy)
    if self.blockInput then return false end
    
    if self.draggedElement and self.draggedElement.touchmoved then
        return self.draggedElement:touchmoved(id, x, y, dx, dy)
    end
    
    -- Обновляем hover состояние
    local newHovered = nil
    for i = #self._elements, 1, -1 do
        local element = self._elements[i]
        if element and element.visible and element:isInside(x, y) then
            newHovered = element
            break
        end
    end
    self:setHoveredElement(newHovered)
    
    return false
end

function UIManager:touchreleased(id, x, y)
    if self.blockInput then return false end
    
    if self.draggedElement then
        if self.draggedElement.touchreleased then
            self.draggedElement:touchreleased(id, x, y)
        end
        self.draggedElement = nil
    end
    
    if self.focusedElement and self.focusedElement.touchreleased then
        return self.focusedElement:touchreleased(id, x, y)
    end
    
    self.focusedElement = nil
    return false
end

function UIManager:keypressed(key)
    if self.blockInput then return false end
    if self.activeInputElement and self.activeInputElement.keypressed then
        return self.activeInputElement:keypressed(key)
    end
    return false
end

function UIManager:textinput(text)
    if self.blockInput then return false end
    if self.activeInputElement and self.activeInputElement.textinput then
        return self.activeInputElement:textinput(text)
    end
    return false
end

-- Блокировка ввода --------------------------------------------------
function UIManager:setInputBlocked(blocked)
    self.blockInput = blocked
    if blocked then
        self:setActiveInput(nil)
        self:setHoveredElement(nil)
        self.draggedElement = nil
        self.focusedElement = nil
    end
end

return UIManager