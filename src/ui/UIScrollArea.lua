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
    self._touchId = nil -- Для отслеживания конкретного касания
    self.scrollFriction = 0.95 -- Трение для плавности
    self.scrollVelocity = 0
    self.maxOverscroll = 50 -- Максимальное "перетягивание" за границы
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
    self._touchId = id
    self.scrollVelocity = 0 -- Сбрасываем скорость при новом касании
    return true
end

function UIScrollArea:touchmoved(id, x, y, dx, dy)
    if self._isScrolling and self._touchId == id then
        self.scrollVelocity = -dy -- Запоминаем скорость для инерции
        
        local newScrollY = self.scrollY - dy
        
        -- Ограничиваем скролл с возможностью небольшого "перетягивания"
        local maxScroll = self.contentHeight - self.height
        if maxScroll > 0 then
            if newScrollY < -self.maxOverscroll then
                newScrollY = -self.maxOverscroll + (newScrollY + self.maxOverscroll) * 0.2
            elseif newScrollY > maxScroll + self.maxOverscroll then
                newScrollY = maxScroll + self.maxOverscroll + (newScrollY - maxScroll - self.maxOverscroll) * 0.2
            end
        else
            newScrollY = 0 -- Если контент меньше области, не скроллим
        end
        
        self.scrollY = newScrollY
        return true
    end
    return false
end

function UIScrollArea:touchreleased(id, x, y)
    if self._touchId == id then
        self._isScrolling = false
        self._touchId = nil
    end
    return false
end

function UIScrollArea:update(dt)
    -- Применяем инерцию, если не скроллим вручную
    if not self._isScrolling and math.abs(self.scrollVelocity) > 0.1 then
        self.scrollVelocity = self.scrollVelocity * self.scrollFriction
        local newScrollY = self.scrollY + self.scrollVelocity
    
        local maxScroll = math.max(0, self.contentHeight - self.height)
        
        -- Если вышли за границы, уменьшаем скорость
        if newScrollY < 0 or newScrollY > maxScroll then
            self.scrollVelocity = self.scrollVelocity * 0.6
        end
        
        -- Ограничиваем скролл
        if newScrollY < 0 then
            newScrollY = 0
            self.scrollVelocity = 0
        elseif newScrollY > maxScroll then
            newScrollY = maxScroll
            self.scrollVelocity = 0
        end
        
        self.scrollY = newScrollY
    end
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