-- src/core/SpawnManager.lua
local SpawnManager = {}
local DebugLog = require("src.utils.debuglog")

function SpawnManager:new(world, objectManager)
    return setmetatable({
        world = world,
        objectManager = objectManager,
        spawnAreas = {},
        spawnTimer = 0,
        spawnInterval = 5, -- Спавн каждые 5 секунд (для теста)
    }, {__index = SpawnManager})
end

-- Основные методы спавна
function SpawnManager:spawnMob(x, y)
    local Mob = require("src.objects.active.Mob")
    local mob = Mob:new(self.world, x or math.random(300, 500), y or math.random(200, 400))
    self.objectManager:add(mob)
    
    return mob
end

function SpawnManager:spawnItem(itemType, x, y)
    local Item = require("src.objects.items.Item")
    local item = Item:new(x or math.random(100, 700), y or math.random(100, 500), itemType)
    self.objectManager:add(item)
    return item
end

function SpawnManager:spawnPlayer(x, y)
    local Player = require("src.objects.active.Player")
    local player = Player:new(self.world, x, y)
    self.objectManager:add(player)
    DebugLog.print("Spawned player at "..x..","..y)
    return player
end

function SpawnManager:spawnInitial()
    -- Пример базовых сущностей (можно кастомизировать)
    -- Стены
    local Wall = require("src.objects.static.Wall")
    self.objectManager:add(Wall:new(self.world, 200, 100, 50, 200))
    self.objectManager:add(Wall:new(self.world, 400, 300, 150, 30))

    -- Мобы
    self:spawnMob(350, 250)
    self:spawnMob(500, 300)

    -- Предметы
    self:spawnItem("heal", 250, 150)
    self:spawnItem("shield", 450, 200)

    DebugLog.print("Initial spawn complete.")
end

-- Обновление (для периодического спавна)
function SpawnManager:update(dt)
    self.spawnTimer = self.spawnTimer + dt
    if self.spawnTimer >= self.spawnInterval then
        self:spawnMob() -- Спавним случайного моба
        self.spawnTimer = 0
    end
end

return SpawnManager