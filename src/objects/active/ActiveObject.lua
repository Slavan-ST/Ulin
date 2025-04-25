local class = require("lib.middleclass")
local GameObject = require("src.objects.GameObject")

local ActiveObject = class("ActiveObject", GameObject)

function ActiveObject:initialize(world, x, y, radius)
    GameObject.initialize(self, world, x, y)

    self.radius = radius or 16
    self.speed = 100

    self.body = love.physics.newBody(world, x, y, "dynamic")
    self.shape = love.physics.newCircleShape(self.radius)
    self.fixture = love.physics.newFixture(self.body, self.shape)

    self.body:setFixedRotation(true)
end

function ActiveObject:update(dt)
    -- можно переопределять, добавим базовую обработку
end

function ActiveObject:draw()
    local x, y = self.body:getPosition()
    love.graphics.setColor(0.2, 0.8, 0.2)
    love.graphics.circle("fill", x, y, self.radius)
    love.graphics.setColor(1, 1, 1)
end

return ActiveObject