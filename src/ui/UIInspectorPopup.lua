local class = require("lib.middleclass")
local UIPopup = require("src.ui.UIPopup")
local UIElement = require("src.ui.UIElement")
local UIScrollArea = require("src.ui.UIScrollArea")

local UIInspectorPopup = class("UIInspectorPopup", UIPopup)

function UIInspectorPopup:initialize(x, y, w, h, title, target, style)
    UIPopup.initialize(self, x, y, w, h, title)
    self.target = target
    self.style = style or {
        bg = {0.1, 0.1, 0.2, 0.9},
        header = {0.2, 0.2, 0.3},
        text = {1, 1, 1},
        closeButton = {0.9, 0.2, 0.2}
    }
    
    self.font = love.graphics.newFont(12)
    self.itemHeight = 20
    self.zIndex = 1000
    self.draggable = true
    
    -- Инициализация scroll area
    self:initScrollArea(w, h - 30)
    self:populateScrollArea()
end

function UIInspectorPopup:initScrollArea(width, height)
    self.scrollArea = UIScrollArea:new(0, 30, width, height)
    self:addChild(self.scrollArea)
end

function UIInspectorPopup:populateScrollArea()
    self.scrollArea.controls = {}
    local yPos = 0
    
    local function addProperties(t, indent)
        for k, v in pairs(t) do
            if k ~= "__index" then
                self:addPropertyItem(k, v, yPos, indent)
                yPos = yPos + self.itemHeight
                
                if type(v) == "table" then
                    addProperties(v, indent + 1)
                end
            end
        end
    end
    
    addProperties(self.target, 0)
    self.scrollArea:updateContentHeight()
end

function UIInspectorPopup:addPropertyItem(key, value, yPos, indent)
    local propItem = {
        x = 10 + indent * 10,
        y = yPos,
        width = self.scrollArea.width - 20 - indent * 10,
        height = self.itemHeight,
        draw = function(self)
            local text = string.rep(" ", indent) .. tostring(key) .. ": " .. tostring(value)
            love.graphics.setColor(self.parent.parent.style.text)
            love.graphics.print(text, self.x, self.y)
        end,
        isInside = function(self, x, y)
            return x >= self.x and x <= self.x + self.width and
                   y >= self.y and y <= self.y + self.height
        end,
        parent = self.scrollArea
    }
    
    table.insert(self.scrollArea.controls, propItem)
end

function UIInspectorPopup:drawHeader()
    -- Заголовок
    love.graphics.setColor(self.style.header)
    love.graphics.rectangle("fill", 0, 0, self.width, 30)
    love.graphics.setColor(self.style.text)
    love.graphics.print(self.title, 10, 5)
    
    -- Кнопка закрытия
    love.graphics.setColor(self.style.closeButton)
    love.graphics.rectangle("fill", self.width - 30, 0, 30, 30)
    love.graphics.setColor(self.style.text)
    love.graphics.print("X", self.width - 20, 5)
end

function UIInspectorPopup:draw()
    if not self.visible then return end
    
    love.graphics.push("all")
    love.graphics.translate(self.x, self.y)
    
    -- Фон
    love.graphics.setColor(self.style.bg)
    love.graphics.rectangle("fill", 0, 0, self.width, self.height, 5)
    
    -- Заголовок и кнопка закрытия
    self:drawHeader()
    
    -- Отрисовка скролл-области
    UIElement.withScissor(self, self:redraw_control())
    love.graphics.pop()

end

function UIInspectorPopup:redraw_control()
    love.graphics.translate(0, -self.scrollArea.scrollY)
    
    for _, control in ipairs(self.scrollArea.controls) do
        love.graphics.push()
        love.graphics.translate(control.x, 30 + control.y)
        if control.draw then control:draw() end
        love.graphics.pop()
    end
    end

function UIInspectorPopup:touchpressed(id, x, y)
    if not self:isInside(x, y) then return false end
    
    -- Преобразуем координаты в локальные
    local localX, localY = x - self.x, y - self.y
    
    -- Кнопка закрытия
    if localX >= self.width - 30 and localX <= self.width and
       localY >= 0 and localY <= 30 then
        self.visible = false
        return true
    end
    
    -- Перетаскивание (обрабатывается родительским классом)
    if localY <= 30 then
        return UIPopup.touchpressed(self, id, x, y)
    end
    
    -- Клик по содержимому скролла
    if self.scrollArea:touchpressed(id, localX, localY - 30 + self.scrollArea.scrollY) then
        return true
    end
    
    return false
end

function UIInspectorPopup:update(dt)
    self.scrollArea:update(dt)
end

function UIInspectorPopup:touchmoved(id, x, y, dx, dy)
    -- Стандартное перетаскивание попапа
    if UIPopup.touchmoved(self, id, x, y, dx, dy) then
        return true
    end
    
    -- Обработка скролла в контентной области
    local localX, localY = x - self.x, y - self.y
    if localY > 30 then
        return self.scrollArea:touchmoved(id, localX, localY - 30 + self.scrollArea.scrollY, dx, dy)
    end
    
    return false
end

return UIInspectorPopup