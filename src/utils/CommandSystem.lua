-- src/utils/CommandSystem.lua
local class = require("lib.middleclass")
local CommandSystem = class("CommandSystem")

function CommandSystem:initialize(world, player, objectManager, spawnManager)
    self.world = world
    self.player = player
    self.objectManager = objectManager
    self.spawnManager = spawnManager
    self:registerCoreCommands()
end

function CommandSystem:registerCoreCommands()
    local cm = require("src.utils.ConsoleManager")

    -- Команда спавна
    cm:registerCommand("spawn", "Spawn objects: spawn [mob|item] [x] [y] [type]", function(type, x, y, ...)
        x, y = tonumber(x), tonumber(y)
        if type == "mob" then
            local mob = self.spawnManager:spawnMob(x, y)
            return string.format("Spawned mob at %.1f,%.1f", mob.body:getPosition())
        elseif type == "item" then
            local itemType = ...
            local item = self.spawnManager:spawnItem(itemType or "default", x, y)
            return string.format("Spawned %s item at %.1f,%.1f", itemType or "default", x, y)
        end
        return "Unknown type: "..(type or "nil")
    end)

    -- Команда телепортации
    cm:registerCommand("tp", "Teleport player: tp [x] [y]", function(x, y)
        x, y = tonumber(x), tonumber(y)
        if x and y then
            self.player.body:setPosition(x, y)
            return string.format("Player teleported to %.1f,%.1f", x, y)
        end
        return "Invalid coordinates"
    end)

    -- Команда урона
    cm:registerCommand("damage", "Damage player: damage [amount]", function(amount)
        amount = tonumber(amount) or 10
        local alive = self.player.stats:takeDamage(amount)
        return alive and string.format("Player took %d damage (HP: %d/%d)", 
               amount, self.player.stats.health, self.player.stats.maxHealth) 
               or "Player died!"
    end)

    -- Команда лечения
    cm:registerCommand("heal", "Heal player: heal [amount]", function(amount)
        amount = tonumber(amount) or 25
        self.player.stats:heal(amount)
        return string.format("Player healed for %d (HP: %d/%d)", 
               amount, self.player.stats.health, self.player.stats.maxHealth)
    end)
end

return CommandSystem