local Game = {}

local Camera = require("src.core.camera")
local Joystick = require("src.ui.joystick")
local DebugLog = require("src.utils.debuglog")
local Wall = require("src.objects.static.Wall")
local Player = require("src.objects.active.Player")
local Item = require("src.objects.items.Item")
local ObjectManager = require("src.core.ObjectManager")
local SpawnManager = require("src.core.SpawnManager")
local Mob = require("src.objects.active.Mob")


-- В src/core/game.lua:



function Game:load()
    -- === ФИЗИЧЕСКИЙ МИР ===
    self.world = love.physics.newWorld(0, 0, true)

    -- === МЕНЕДЖЕРЫ ===
    self.objects = ObjectManager:new()
    self.spawnManager = SpawnManager:new(self.world, self.objects)

    -- === ИГРОК ===
    self.player = self.spawnManager:spawnPlayer(100, 100)
    self.player.lastDamageTime = 0

    -- === СТАРТОВАЯ ИНИЦИАЛИЗАЦИЯ СПАВНА ===
    self.spawnManager:spawnInitial()

    -- === КАМЕРА ===
    Camera:setTarget(self.player)

    -- === ИНТЕРФЕЙС ===
    Joystick:init()
    
    -- В Game:load()
    local CommandSystem = require("src.utils.CommandSystem")
    self.commandSystem = CommandSystem:new(self.world, self.player, self.objects, self.spawnManager)

    DebugLog.print("Game initialized.")
end

function Game:update(dt)
    self.world:update(dt)
    Joystick:update(dt)
    
    -- Обновляем игрока
    self.player:update(dt, Joystick:getDirection())
    -- Обновляем все объекты через менеджер
    self.objects:update(dt, self.player)
        -- Обновляем менеджер спавна
    self.spawnManager:update(dt)
    

    Camera:update(dt)
end

function Game:draw()
    Camera:attach()

    -- Отрисовываем все объекты через менеджер
    self.objects:draw()

    self.player:draw()

    Camera:detach()

    Joystick:draw()
    --DebugLog.draw()
end

function Game:touchpressed(id, x, y, dx, dy, pressure)
    
    -- Если касание внутри области DebugLog — приоритет
    if DebugLog.isTouchInside(x, y) then
        DebugLog.touchpressed(id, x, y)  -- Передаем все три параметра
        return
    end

    -- В остальных случаях — обычная обработка
    Joystick.touchpressed(id, x, y)

    -- Конвертация координат касания в мировые
    local wx, wy = Camera:screenToWorld(x, y)

    -- Проверка касания интерактивных объектов
    for _, obj in ipairs(self.objects.objects) do
        if obj.onTouch and obj.shape and obj.body then
            local bx, by = obj.body:getPosition()
            local angle = obj.body:getAngle()

            local success, isPointInside = pcall(function()
                return obj.shape:testPoint(bx, by, angle, wx, wy)
            end)

            if success and isPointInside then
                obj:onTouch()
            end
        end
    end
end

function Game:touchmoved(id, x, y, dx, dy, pressure)
    if DebugLog.isTouchInside(x, y) then
        DebugLog.touchmoved(id, x, y, dx, dy)  -- Передаем все параметры
    else
        Joystick.touchmoved(id, x, y)
    end
end

function Game:touchreleased(id, x, y, dx, dy, pressure)
    if DebugLog.isTouchInside(x, y) then
        DebugLog.touchreleased(id, x, y)  -- Передаем все три параметра
    else
        Joystick.touchreleased(id, x, y)
    end
end

function Game.textinput(t)
    DebugLog.textinput(t)
end

function Game.keypressed(key)
    DebugLog.keypressed(key)
end


return Game