local Inventory = {}
local DebugLog = require("src.utils.debuglog")
Inventory.__index = Inventory

function Inventory:new()
    return setmetatable({ items = {} }, Inventory)
end

function Inventory:add(item)
    table.insert(self.items, item)
    DebugLog.print("Added to inventory: " .. item.name)
end

function Inventory:draw()
    for i, item in ipairs(self.items) do
        love.graphics.print(item.name, 10, i * 16)
    end
end

return Inventory