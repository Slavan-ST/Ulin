
-- src/objects/active/Player.lua
local class = require("lib.middleclass")
local ActiveObject = require("src.objects.active.ActiveObject")
local Inventory = require("src.core.Inventory")
local Stats = require("src.core.Stats") -- Добавляем

local Player = class("Player", ActiveObject)

function Player:initialize(world, x, y)
    ActiveObject.initialize(self, world, x, y, 16)
    self.inventory = Inventory:new()
    self.stats = Stats:new(200) -- Здоровье игрока
end

-- Добавим метод для отрисовки здоровья
function Player:draw()
    ActiveObject.draw(self) -- Родительский draw
    
    -- Рисуем healthbar над игроком
    local x, y = self.body:getPosition()
    local w, h = 40, 5
    local healthPercent = self.stats.health / self.stats.maxHealth
    
    love.graphics.setColor(0.5, 0, 0)
    love.graphics.rectangle("fill", x - w/2, y - 30, w, h)
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", x - w/2, y - 30, w * healthPercent, h)
    love.graphics.setColor(1, 1, 1)
end



-- Обновление с использованием direction как таблицы {x, y}
function Player:update(dt, direction)
    -- Если direction существует и не пустое
    if direction and direction.x ~= nil and direction.y ~= nil then
        local vx = direction.x * self.speed
        local vy = direction.y * self.speed
        self.body:setLinearVelocity(vx, vy)
    else
        self.body:setLinearVelocity(0, 0)
    end
end

return Player