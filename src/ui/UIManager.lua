local class = require("lib.middleclass")
local UIElement = require "src.ui.UIElement"
local UIManager = class("UIManager")

function UIManager:initialize()
    self.elements = {}         -- Все UI элементы
    self.focusedElement = nil  -- Элемент в фокусе (кликнутый)
    self.activeInputElement = nil -- Активный элемент ввода
    self.hoveredElement = nil  -- Элемент под курсором/касанием
    self.draggedElement = nil  -- Элемент в процессе перетаскивания
    self.blockInput = false    -- Флаг блокировки ввода
end

-- Добавление элемента с автоматической сортировкой по zIndex
function UIManager:add(element)
    if not element then return end
    table.insert(self.elements, element)
    self:sortElements()
end

-- Сортировка элементов по zIndex (от меньшего к большему)
function UIManager:sortElements()
    table.sort(self.elements, function(a, b)
        return (a.zIndex or 0) < (b.zIndex or 0)
    end)
end

-- Удаление элемента и очистка ссылок на него
function UIManager:remove(element)
    if not element then return end
    
    for i, e in ipairs(self.elements) do
        if e == element then
            table.remove(self.elements, i)
            self:clearElementReferences(element)
            break
        end
    end
end

-- Очистка всех ссылок на элемент
function UIManager:clearElementReferences(element)
    if self.focusedElement == element then
        self.focusedElement = nil
    end
    if self.activeInputElement == element then
        self:clearActiveInput()
    end
    if self.hoveredElement == element then
        self:setHoveredElement(nil)
    end
    if self.draggedElement == element then
        self.draggedElement = nil
    end
end

-- Очистка активного элемента ввода
function UIManager:clearActiveInput()
    if self.activeInputElement and self.activeInputElement.setActive then
        self.activeInputElement:setActive(false)
    end
    self.activeInputElement = nil
    love.keyboard.setTextInput(false)
end

-- Установка hovered элемента с вызовом колбэков
function UIManager:setHoveredElement(element)
    if self.hoveredElement == element then return end
    
    -- Уведомляем предыдущий элемент о потере hover
    if self.hoveredElement and self.hoveredElement.onHoverChanged then
        self.hoveredElement:onHoverChanged(false)
    end
    
    self.hoveredElement = element
    
    -- Уведомляем новый элемент о получении hover
    if element and element.onHoverChanged then
        element:onHoverChanged(true)
    end
end

-- Обновление всех элементов
function UIManager:update(dt)
    if self.blockInput then return end
    
    for i = #self.elements, 1, -1 do
        local element = self.elements[i]
        if element and element.visible ~= false and element.update then
            element:update(dt)
        end
    end
end

-- Отрисовка всех элементов в порядке zIndex
function UIManager:draw()
    for _, element in ipairs(self.elements) do
        if element and element.visible ~= false and element.draw then
            element:draw()
        end
    end
end

-- Обработка нажатия (тач/клик)
-- src/ui/UIManager.lua
function UIManager:touchpressed(id, x, y)
    if self.blockInput then return false end
    
    -- Снимаем фокус ввода если клик был мимо активного элемента
    if self.activeInputElement then
        if not (self.activeInputElement.isInside and self.activeInputElement:isInside(x, y)) then
            self:clearActiveInput()
        end
    end

    -- Обработка сверху вниз по zIndex
    for i = #self.elements, 1, -1 do
        local element = self.elements[i]
        if element and element.visible ~= false then
            -- Проверяем наличие метода isInside перед вызовом
            local isInside = element.isInside and element:isInside(x, y)
            if isInside and element.touchpressed then
                if element:touchpressed(id, x, y) then
                    self.focusedElement = element
                    
                    if element.draggable then
                        self.draggedElement = element
                    end
                    
                    if element.setActive then
                        self:clearActiveInput()
                        element:setActive(true)
                        self.activeInputElement = element
                        love.keyboard.setTextInput(true)
                    end
                    
                    return true
                end
            end
        end
    end
    
    return false
end

-- Обработка перемещения (тач/мышь)
function UIManager:touchmoved(id, x, y, dx, dy)
    if self.blockInput then return false end
    
    local handled = false
    
    -- В первую очередь - перетаскивание
    if self.draggedElement and self.draggedElement.touchmoved then
        handled = self.draggedElement:touchmoved(id, x, y, dx, dy)
    end
    
    -- Обновление hover-эффектов
    local newHovered = nil
    for i = #self.elements, 1, -1 do
        local element = self.elements[i]
        if element and element.visible ~= false and element:isInside(x, y) then
            newHovered = element
            break  -- Берем верхний элемент
        end
    end
    self:setHoveredElement(newHovered)
    
    -- Передаем событие hovered элементу
    if self.hoveredElement and self.hoveredElement.touchmoved then
        handled = handled or self.hoveredElement:touchmoved(id, x, y, dx, dy)
    end
    
    return handled
end

-- Обработка отпускания (тач/мышь)
function UIManager:touchreleased(id, x, y)
    if self.blockInput then return false end
    
    local handled = false
    
    -- Завершение перетаскивания
    if self.draggedElement then
        if self.draggedElement.touchreleased then
            handled = self.draggedElement:touchreleased(id, x, y)
        end
        self.draggedElement = nil
    end
    
    -- Клик по элементу
    if self.focusedElement and self.focusedElement.touchreleased then
        handled = handled or self.focusedElement:touchreleased(id, x, y)
    end
    
    self.focusedElement = nil
    
    return handled
end

-- Обработка нажатия клавиши
function UIManager:keypressed(key)
    if self.blockInput then return false end
    
    -- Сначала активному элементу ввода
    if self.activeInputElement and self.activeInputElement.keypressed then
        if self.activeInputElement:keypressed(key) then
            return true
        end
    end
    
    -- Затем остальным элементам
    for i = #self.elements, 1, -1 do
        local element = self.elements[i]
        if element and element.visible ~= false and element.keypressed then
            if element:keypressed(key) then
                return true
            end
        end
    end
    
    return false
end

-- Обработка текстового ввода
function UIManager:textinput(text)
    if self.blockInput then return false end
    
    if self.activeInputElement and self.activeInputElement.textinput then
        return self.activeInputElement:textinput(text)
    end
    return false
end

-- Блокировка/разблокировка ввода
function UIManager:setInputBlocked(blocked)
    self.blockInput = blocked
end

return UIManager