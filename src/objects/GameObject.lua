local class = require("lib.middleclass")

local GameObject = class("GameObject")

function GameObject:initialize(world, x, y)
    self.world = world
    self.x = x or 0
    self.y = y or 0
end

function GameObject:update(dt)
    -- Переопределяется потомками при необходимости
end

function GameObject:draw()
    -- Переопределяется потомками
end

return GameObject