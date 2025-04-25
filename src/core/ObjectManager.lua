local ObjectManager = {}
local DebugLog = require("src.utils.debuglog")
ObjectManager.__index = ObjectManager

local Item = require("src.objects.items.Item")



function ObjectManager:new()
    return setmetatable({ objects = {} }, self)
end

function ObjectManager:add(obj)
    table.insert(self.objects, obj)
end

function ObjectManager:update(dt, player)
    for i = #self.objects, 1, -1 do
        local obj = self.objects[i]

        if obj.isInstanceOf and obj:isInstanceOf(Item) then
            obj:update(dt, player)
        end

        if obj.picked then
            table.remove(self.objects, i)
        end
    end
end

function ObjectManager:draw()
    for _, obj in ipairs(self.objects) do
        if obj.draw then
            obj:draw()
        end
    end
end

-- В src/core/ObjectManager.lua:

function ObjectManager:getAll(filterType)
    if not filterType then return self.objects end
    
    local filtered = {}
    for _, obj in ipairs(self.objects) do
        if obj.class and obj.class.name == filterType then
            table.insert(filtered, obj)
        end
    end
    return filtered
end

function ObjectManager:getNearby(x, y, radius, filterType)
    local result = {}
    for _, obj in ipairs(self:getAll(filterType)) do
        local ox, oy = obj.body and obj.body:getPosition() or obj.x, obj.y
        local dist = math.sqrt((ox - x)^2 + (oy - y)^2)
        if dist <= radius then
            table.insert(result, obj)
        end
    end
    return result
end

return ObjectManager