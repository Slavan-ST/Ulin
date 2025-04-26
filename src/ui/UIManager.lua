local class = require("lib.middleclass")
local UIElement = require("src.ui.UIElement")

local UIManager = class("UIManager", UIElement)

function UIManager:initialize()
    UIElement.initialize(self, 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    self.blockInput = false
    self.activeInputElement = nil
    self.focusedElement = nil
    self.hoveredElement = nil
    self.draggedElement = nil
    self.elements = {} -- Основной список элементов (дублирует self.children, но для совместимости)
end

-- Добавление элемента с сортировкой
function UIManager:add(element)
    if not element then return end
    self:addChild(element) -- Используем родительский метод
    table.insert(self.elements, element)
    self:sortElements()
end

-- Удаление элемента
function UIManager:remove(element)
    if not element then return end
    
    for i, e in ipairs(self.elements) do
        if e == element then
            table.remove(self.elements, i)
            self:removeChild(element) -- Нужно добавить этот метод в UIElement
            self:clearElementReferences(element)
            break
        end
    end
end

-- Очистка ссылок на элемент
function UIManager:clearElementReferences(element)
    if self.focusedElement == element then
        self.focusedElement = nil
    end
    if self.activeInputElement == element then
        self:setActiveInput(nil)
    end
    if self.hoveredElement == element then
        self:setHoveredElement(nil)
    end
    if self.draggedElement == element then
        self.draggedElement = nil
    end
end

-- Сортировка элементов по zIndex
function UIManager:sortElements()
    table.sort(self.elements, function(a, b)
        return (a.zIndex or 0) < (b.zIndex or 0)
    end)
    self:sortChildren() -- Сортируем и дочерние элементы
end

-- Установка активного элемента ввода
function UIManager:setActiveInput(element)
    if self.activeInputElement then
        self.activeInputElement:setActive(false)
    end
    self.activeInputElement = element
    if element then
        element:setActive(true)
        love.keyboard.setTextInput(true)
    else
        love.keyboard.setTextInput(false)
    end
end

-- Установка hovered элемента
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

-- Обработчики событий (переопределенные)
function UIManager:touchpressed(id, x, y)
    if self.blockInput then return false end
    
    if self.activeInputElement and not self.activeInputElement:isInside(x, y) then
        self:setActiveInput(nil)
    end

    -- Обработка сверху вниз по zIndex
    for i = #self.elements, 1, -1 do
        local element = self.elements[i]
        if element and element.visible ~= false and element:isInside(x, y) and element.touchpressed then
            if element:touchpressed(id, x, y) then
                self.focusedElement = element
                if element.draggable then
                    self.draggedElement = element
                end
                return true
            end
        end
    end
    
    return false
end

function UIManager:touchmoved(id, x, y, dx, dy)
    if self.blockInput then return false end
    
    -- Передаем событие в draggedElement (если есть)
    if self.draggedElement and self.draggedElement.touchmoved then
        return self.draggedElement:touchmoved(id, x, y, dx, dy)
    end
    
    -- Обновляем hover состояние
    local newHovered = nil
    for i = #self.elements, 1, -1 do
        local element = self.elements[i]
        if element and element.visible ~= false and element:isInside(x, y) then
            newHovered = element
            break
        end
    end
    self:setHoveredElement(newHovered)
    
    return false
end



function UIManager:touchreleased(id, x, y)
    if self.blockInput then return false end
    
    -- Завершение перетаскивания
    if self.draggedElement then
        if self.draggedElement.touchreleased then
            self.draggedElement:touchreleased(id, x, y)
        end
        self.draggedElement = nil
    end
    
    -- Клик по элементу
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

-- Блокировка ввода
function UIManager:setInputBlocked(blocked)
    self.blockInput = blocked
end

return UIManager