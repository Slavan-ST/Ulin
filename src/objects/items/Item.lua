local class = require("lib.middleclass")
local GameObject = require("src.objects.GameObject") -- если есть базовый класс

local Item = class("Item", GameObject)

function Item:initialize(x, y, name)
    self.x = x
    self.y = y
    self.name = name or "Unknown Item"
    self.radius = 16
    self.picked = false
end

function Item:draw()
    love.graphics.setColor(1, 1, 0)
    love.graphics.circle("fill", self.x, self.y, 8)
    love.graphics.setColor(1, 1, 1)
end

function Item:update(dt, player)
    local px, py = player.body:getPosition()
    local dx = self.x - px
    local dy = self.y - py

    if dx * dx + dy * dy < self.radius * self.radius then
        player.inventory:add(self)
        self.picked = true
    end
end

return Item