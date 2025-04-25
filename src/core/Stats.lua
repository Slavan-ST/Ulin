-- src/core/Stats.lua
local Stats = {}
Stats.__index = Stats

function Stats:new(maxHealth)
    return setmetatable({
        maxHealth = maxHealth or 100,
        health = maxHealth or 100,
        isAlive = true
    }, Stats)
end

function Stats:takeDamage(amount)
    self.health = math.max(0, self.health - amount)
    self.isAlive = self.health > 0
    return self.isAlive
end

function Stats:heal(amount)
    self.health = math.min(self.maxHealth, self.health + amount)
end

return Stats