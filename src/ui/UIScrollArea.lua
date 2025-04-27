local class = require("lib.middleclass")
local UIElement = require("src.ui.UIElement")

local UIScrollArea = class("UIScrollArea", UIElement)

function UIScrollArea:initialize(x, y, width, height, borderPadding)
    UIElement.initialize(self, x, y, width, height)
    self.scrollY = 0
    self.scrollSpeed = 20
    self.contentHeight = height
    self.controls = {} -- Элементы для скролла
    self._isScrolling = false
    self.borderPadding = borderPadding or 10  -- Отступ по умолчанию 10
end

function UIScrollArea:draw()
    -- Отрисовка основной области прокрутки
    love.graphics.setColor(0.9, 0.9, 0.9)  -- Светлый серый цвет для основной области
    love.graphics.rectangle("fill", self._absX, self._absY, self.width, self.height)

    -- Отрисовка контейнера для элементов
    love.graphics.setColor(0.5, 0.5, 0.5)  -- Более темный цвет для контейнера
    love.graphics.rectangle("fill", self._absX + self.borderPadding, self._absY + self.borderPadding, 
                            self.width - 2 * self.borderPadding, self.height - 2 * self.borderPadding)
    
    -- Отрисовка элементов внутри контейнера
    self:withScissor(function()
        love.graphics.push()

        -- Прокачиваем всю область прокрутки
        love.graphics.translate(0, -self.scrollY)  -- Прокачиваем все элементы в соответствии с прокруткой

        -- Отрисовка детей
        UIElement.draw(self)

        -- Отрисовка элементов внутри контейнера
        for _, control in ipairs(self.controls) do
            love.graphics.push()

            -- Прокачиваем координаты каждого элемента в пределах UIScrollArea
            love.graphics.translate(self._absX + control.x, self._absY + control.y - self.scrollY)

            if control.draw then
                control:draw()
            end

            love.graphics.pop()
        end
        
        love.graphics.pop()
    end)
end

function UIScrollArea:touchreleased(id, x, y)
    self._isScrolling = false
    return false
end

function UIScrollArea:touchpressed(id, x, y)
    local localX = x - self._absX
    local localY = y - self._absY + self.scrollY  -- Добавляем scrollY

    -- Проверяем клик по элементам с учётом отступов
    for i = #self.controls, 1, -1 do
        local control = self.controls[i]
        -- Уменьшаем размеры контролов для предотвращения перехвата в области отступов
        local adjustedWidth = control.width - 2 * self.borderPadding
        local adjustedHeight = control.height - 2 * self.borderPadding
        local adjustedX = control.x + self.borderPadding
        local adjustedY = control.y + self.borderPadding - self.scrollY  -- Корректируем Y-координату

        if control and control.isInside and control:isInside(localX, localY) then
            if localX >= adjustedX and localX <= adjustedX + adjustedWidth and 
               localY >= adjustedY and localY <= adjustedY + adjustedHeight then
                if control.touchpressed then
                    return control:touchpressed(id, localX, localY)
                end
            end
        end
    end
    
    -- Начинаем скроллинг, если не было нажатия на элемент
    self._isScrolling = true
    return true
end

function UIScrollArea:touchmoved(id, x, y, dx, dy)
    if self._isScrolling then
        local newScrollY = self.scrollY - dy
        -- Ограничиваем прокрутку с учётом высоты контента
        self.scrollY = math.max(0, math.min(newScrollY, self.contentHeight - self.height))
        return true
    end
    return false
end

function UIScrollArea:updateContentHeight()
    local maxY = 0
    -- Обновляем высоту контента в зависимости от высоты элементов
    for _, control in ipairs(self.controls) do
        local bottom = control.y + control.height
        if bottom > maxY then maxY = bottom end
    end
    self.contentHeight = math.max(maxY, self.height)
end

function UIScrollArea:addControl(control)
    -- Добавляем контрол в список дочерних элементов
    table.insert(self.controls, control)

    -- Задаём локальные координаты элемента относительно UIScrollArea
    control.x = control.x - self._absX
    control.y = control.y - self._absY
end

return UIScrollArea