local class = require("lib.middleclass")
local UIPopup = require("src.ui.UIPopup")
local UIScrollArea = require("src.ui.UIScrollArea")
local UIButton = require("src.ui.UIButton")

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
    
    -- Инициализация кнопки закрытия
    self:initCloseButton()
    
    -- Инициализация scroll area
    self:initScrollArea(w, h - 30)
    self:populateScrollArea()
end

function UIInspectorPopup:initCloseButton()
    self.closeButton = UIButton:new(
        self.width - 30, 0, 30, 30,
        "X",
        function() 
            self.visible = false 
        end
    )
    
    -- Настройка стиля кнопки
    self.closeButton.color = self.style.closeButton
    self.closeButton.pressedColor = {1, 0.3, 0.3}
    self.closeButton.textColor = self.style.text
    self.closeButton.zIndex = self.zIndex + 1
    
    self:addChild(self.closeButton)
end

function UIInspectorPopup:initScrollArea(width, height)
    self.scrollArea = UIScrollArea:new(0, 30, width, height)
    self.scrollArea.parent = self  -- Устанавливаем родителя
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
end

function UIInspectorPopup:draw()
    if not self.visible then return end
    
    love.graphics.push("all")
    love.graphics.translate(self.x, self.y)
    
    -- Фон
    love.graphics.setColor(self.style.bg)
    love.graphics.rectangle("fill", 0, 0, self.width, self.height, 5)
    
    -- Заголовок
    self:drawHeader()
    
    -- Отрисовка скролл-области через withScissor
    self.scrollArea:draw()
    
    love.graphics.pop()
end

function UIInspectorPopup:touchpressed(id, x, y)
    if not self:isInside(x, y) then return false end
    
    local localX, localY = x - self.x, y - self.y
    
    -- Перетаскивание заголовка
    if localY <= 30 then
        return UIPopup.touchpressed(self, id, x, y)
    end
    
    -- Клик по содержимому скролла
    return self.scrollArea:touchpressed(id, localX, localY)
end

function UIInspectorPopup:touchmoved(id, x, y, dx, dy)
    local localY = y - self.y
    
    -- Если касаемся заголовка - перетаскивание
    if localY <= 30 then
        return UIPopup.touchmoved(self, id, x, y, dx, dy)
    end
    
    -- Иначе - скролл
    return self.scrollArea:touchmoved(id, x, y, dx, dy)
end

function UIInspectorPopup:update(dt)
    self.scrollArea:update(dt)
end

return UIInspectorPopup