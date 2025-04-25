-- src/objects/active/Mob.lua
local class = require("lib.middleclass")
local ActiveObject = require("src.objects.active.ActiveObject")
local Stats = require("src.core.Stats")

local Mob = class("Mob", ActiveObject)

function Mob:initialize(world, x, y)
    ActiveObject.initialize(self, world, x, y, 14) -- Чуть меньше игрока
    self.stats = Stats:new(50) -- Мобы слабее
    self.speed = 60 -- Медленнее игрока
    self.color = {0.8, 0.2, 0.2} -- Красноватый
end

function Mob:update(dt, player)
    if not self.stats.isAlive then return end
    
    -- Простейший AI: движение к игроку
    local px, py = player.body:getPosition()
    local mx, my = self.body:getPosition()
    
    local dx = px - mx
    local dy = py - my
    local dist = math.sqrt(dx*dx + dy*dy)
    
    if dist > 0 then
        dx = dx / dist * self.speed
        dy = dy / dist * self.speed
        self.body:setLinearVelocity(dx, dy)
    end
end

function Mob:draw()
    if not self.stats.isAlive then return end
    
    local x, y = self.body:getPosition()
    
    -- Тело моба
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", x, y, self.radius)
    
    -- Healthbar
    local w, h = 30, 4
    local healthPercent = self.stats.health / self.stats.maxHealth
    
    love.graphics.setColor(0.3, 0, 0)
    love.graphics.rectangle("fill", x - w/2, y - 25, w, h)
    love.graphics.setColor(0.8, 0, 0)
    love.graphics.rectangle("fill", x - w/2, y - 25, w * healthPercent, h)
    love.graphics.setColor(1, 1, 1)
end

return Mob