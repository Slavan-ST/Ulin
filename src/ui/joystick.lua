local DebugLog = require("src.utils.debuglog")
local Joystick = {}

Joystick.baseRadius = 50
Joystick.knobRadius = 20
Joystick.active = false
Joystick.identifier = nil
Joystick.baseX, Joystick.baseY = 80, love.graphics.getHeight() - 80
Joystick.knobX, Joystick.knobY = Joystick.baseX, Joystick.baseY
Joystick.dx, Joystick.dy = 0, 0



function Joystick.update()
    if not Joystick.active then
        Joystick.dx, Joystick.dy = 0, 0
    end
end

function Joystick.draw()
    love.graphics.setColor(0.3, 0.3, 0.3, 0.5)
    love.graphics.circle("fill", Joystick.baseX, Joystick.baseY, Joystick.baseRadius)

    if Joystick.active then
        love.graphics.setColor(1, 1, 1, 0.8)
        love.graphics.circle("fill", Joystick.knobX, Joystick.knobY, Joystick.knobRadius)
    end
end

function Joystick.touchpressed(id, x, y, dx, dy, pressure)
    

    local dist = math.sqrt((x - Joystick.baseX)^2 + (y - Joystick.baseY)^2)
    if dist <= Joystick.baseRadius then
        Joystick.active = true
        Joystick.identifier = id
        Joystick.updatePosition(x, y)
        
    end
end

function Joystick.touchmoved(id, x, y)
    if Joystick.active and id == Joystick.identifier then
        
        Joystick.updatePosition(x, y)
    end
end

function Joystick.touchreleased(id, x, y)
    if Joystick.active and id == Joystick.identifier then
        Joystick.active = false
        Joystick.identifier = nil
        Joystick.knobX, Joystick.knobY = Joystick.baseX, Joystick.baseY
        Joystick.dx, Joystick.dy = 0, 0
    end
end

function Joystick.updatePosition(x, y)
    

    local dx = x - Joystick.baseX
    local dy = y - Joystick.baseY
    local dist = math.sqrt(dx * dx + dy * dy)
    local maxDist = Joystick.baseRadius

    if dist > maxDist then
        dx = dx / dist * maxDist
        dy = dy / dist * maxDist
    end

    Joystick.knobX = Joystick.baseX + dx
    Joystick.knobY = Joystick.baseY + dy
    Joystick.dx = dx / maxDist
    Joystick.dy = dy / maxDist
end

function Joystick.getDirection()
    return {x = Joystick.dx, y = Joystick.dy}
end

function Joystick.init()
    Joystick.baseRadius = 50
    Joystick.knobRadius = 20
    Joystick.active = false
    Joystick.identifier = nil
    Joystick.baseX = 80
    Joystick.baseY = love.graphics.getHeight() - 80
    Joystick.knobX = Joystick.baseX
    Joystick.knobY = Joystick.baseY
    Joystick.dx = 0
    Joystick.dy = 0
end

return Joystick