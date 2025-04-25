local class = require("lib.middleclass")
local UIPopup = require("src.ui.UIPopup")
local UIScrollArea = require("src.ui.UIScrollArea")
local UIElement = require "src.ui.UIElement"

local UIInspectorPopup = class("UIInspectorPopup", UIPopup, UIElement)


function UIInspectorPopup:initialize(x, y, w, h, title, target)
    UIPopup.initialize(self, x, y, w, h, title)
    self.target = target
    self.font = love.graphics.newFont(12)
    self.itemHeight = 20
    self.zIndex = 1000
    
    -- Создаем область скролла для содержимого
    local scrollAreaHeight = h - 30
    self.scrollArea = UIScrollArea:new(
        0, 30,  -- Относительные координаты внутри popup
        w, scrollAreaHeight
    )
    self.scrollArea.parent = self  -- Устанавливаем popup как родителя
    
    -- Заполняем скролл-область элементами свойств
    self:populateScrollArea()
end

function UIInspectorPopup:populateScrollArea()
    self.scrollArea.controls = {}
    
    local yPos = 0
    local function addProperties(t, indent)
        for k, v in pairs(t) do
            local propItem = {
                x = 10 + indent * 10,
                y = yPos,
                width = self.scrollArea.width - 20 - indent * 10,
                height = self.itemHeight,
                draw = function(self)
                    local text = string.rep(" ", indent) .. tostring(k) .. ": " .. tostring(v)
                    love.graphics.print(text, self.x, self.y)
                end,
                isInside = function(self, x, y)
                    return x >= self.x and x <= self.x + self.width and
                           y >= self.y and y <= self.y + self.height
                end,
                parent = self.scrollArea
            }
            
            table.insert(self.scrollArea.controls, propItem)
            yPos = yPos + self.itemHeight
            
            if type(v) == "table" and k ~= "__index" then
                addProperties(v, indent + 1)
            end
        end
    end
    
    addProperties(self.target, 0)
    self.scrollArea:updateContentHeight()
end

function UIInspectorPopup:draw()
    -- Фон
    love.graphics.setColor(0.1, 0.1, 0.2, 0.9)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 5)
    
    -- Заголовок
    love.graphics.setColor(0.2, 0.2, 0.3)
    love.graphics.rectangle("fill", self.x, self.y, self.width, 30)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(self.title, self.x + 10, self.y + 5)
    
    -- Кнопка закрытия
    love.graphics.setColor(0.9, 0.2, 0.2)
    love.graphics.rectangle("fill", self.x + self.width - 30, self.y, 30, 30)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("X", self.x + self.width - 20, self.y + 5)
    
    -- Отрисовка скролл-области с обновленной зоной отсечения
    love.graphics.push("all")
    love.graphics.setScissor(self.x, self.y + 30, self.width, self.height - 30)
    
    -- Смещаем только содержимое скролла
    love.graphics.push()
    love.graphics.translate(0, -self.scrollArea.scrollY)
    
    -- Отрисовываем элементы относительно scrollArea
    for _, control in ipairs(self.scrollArea.controls) do
        love.graphics.push()
        love.graphics.translate(self.x + control.x, self.y + 30 + control.y)
        if control.draw then control:draw() end
        love.graphics.pop()
    end
    
    love.graphics.pop()
    love.graphics.pop()
end

function UIInspectorPopup:touchmoved(id, x, y, dx, dy)
    if self.dragging then
        -- Перемещаем только сам попап
        self.x = self.x + dx
        self.y = self.y + dy
        return true
    end
    
    -- Для скролла используем локальные координаты внутри области контента
    if x >= self.x and x <= self.x + self.width and
       y >= self.y + 30 and y <= self.y + self.height then
        self.scrollArea.scrollY = math.max(0, 
            math.min(self.scrollArea.scrollY - dy, 
                   self.scrollArea.contentHeight - (self.height - 30)))
        return true
    end
    
    return false
end


function UIInspectorPopup:touchpressed(id, x, y)
    -- Кнопка закрытия
    if x >= self.x + self.width - 30 and x <= self.x + self.width and
       y >= self.y and y <= self.y + 30 then
        self.visible = false
        return true
    end
    
    -- Начало перетаскивания
    if y >= self.y and y <= self.y + 30 then
        self.dragging = true
        return true
    end
    
    -- Передаем событие в скролл-область с корректными координатами
    local localX = x - self.scrollArea.x
    local localY = y - self.scrollArea.y + self.scrollArea.scrollY
    
    -- Проверяем клик по элементам в обратном порядке (сверху вниз по z-index)
    for i = #self.scrollArea.controls, 1, -1 do
        local control = self.scrollArea.controls[i]
        if control.isInside and control:isInside(localX, localY) then
            if control.touchpressed then
                return control:touchpressed(id, localX, localY)
            end
        end
    end
    
    -- Если клик не попал ни в один элемент, но был внутри области
    return self.scrollArea:isInside(x, y)
end


function UIInspectorPopup:touchreleased(id, x, y)
    self.dragging = false
    -- Передаем событие в скролл-область
    return self.scrollArea:touchreleased(id, x, y)
end

function UIInspectorPopup:update(dt)
    -- Обновляем скролл-область
    self.scrollArea:update(dt)
end

return UIInspectorPopup
