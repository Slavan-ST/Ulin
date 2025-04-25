local InteractiveObject = {}
InteractiveObject.__index = InteractiveObject

local DebugLog = require("src.utils.debuglog")

function InteractiveObject:new(world, x, y, width, height)
    local self = setmetatable({}, InteractiveObject)

    self.body = love.physics.newBody(world, x, y, "static")
    self.shape = love.physics.newRectangleShape(width, height)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.width = width
    self.height = height

    return self
end

function InteractiveObject:draw()
    love.graphics.setColor(1, 0.8, 0.2) -- Жёлтый
    local x, y = self.body:getPosition()
    love.graphics.rectangle("fill", x - self.width / 2, y - self.height / 2, self.width, self.height)
end

function InteractiveObject:onTouch()
    DebugLog.print("InteractiveObject touched!")
end

return InteractiveObject