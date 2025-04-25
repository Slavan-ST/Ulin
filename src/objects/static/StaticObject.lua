local class = require("lib.middleclass")
local GameObject = require("src.objects.GameObject")

local StaticObject = class("StaticObject", GameObject)

function StaticObject:initialize(world, x, y, w, h)
    GameObject.initialize(self, world, x, y)

    self.w = w or 64
    self.h = h or 64

    self.body = love.physics.newBody(world, x, y, "static")
    self.shape = love.physics.newRectangleShape(self.w, self.h)
    self.fixture = love.physics.newFixture(self.body, self.shape)
end

function StaticObject:draw()
    local x, y = self.body:getPosition()
    local w, h = self.w, self.h
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("fill", x - w / 2, y - h / 2, w, h)
    love.graphics.setColor(1, 1, 1)
end

return StaticObject