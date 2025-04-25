local class = require("lib.middleclass")
local StaticObject = require("src.objects.static.StaticObject")

local Wall = class("Wall", StaticObject)

function Wall:initialize(world, x, y, w, h)
    StaticObject.initialize(self, world, x, y, w, h)
end

return Wall