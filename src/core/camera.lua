local Camera = require("lib.hump.camera")
local DebugLog = require("src.utils.debuglog")
local cam = Camera(0, 0)

function cam:setTarget(target)
    self.target = target
end

function cam:update(dt)
    if self.target and self.target.body then
        local x, y = self.target.body:getPosition()
        self:lookAt(x, y)
    end
end

-- Конвертация координат экрана в координаты мира
function cam:screenToWorld(sx, sy)
    local camX, camY = self:position()
    local scale = self.scale or 1

    local screenW, screenH = love.graphics.getWidth(), love.graphics.getHeight()

    local worldX = (sx - screenW / 2) / scale + camX
    local worldY = (sy - screenH / 2) / scale + camY
    
    return worldX, worldY
end

-- Конвертация координат мира в экранные координаты (по желанию)
function cam:worldToScreen(wx, wy)
    local camX, camY = self:position()
    local scale = self.scale or 1

    local screenW, screenH = love.graphics.getWidth(), love.graphics.getHeight()

    local screenX = (wx - camX) * scale + screenW / 2
    local screenY = (wy - camY) * scale + screenH / 2
    
    return screenX, screenY
end

return cam