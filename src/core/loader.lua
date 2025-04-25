local loader = {}

local DebugLog = require("src.utils.debuglog")
local Game = require("src.core.game")

function loader.load()
    Game:load()
end

function loader.update(dt)
    Game:update(dt)
end

function loader.draw()
    Game:draw()
end

function loader.touchpressed(id, x, y, dx, dy, pressure)
    Game:touchpressed(id, x, y, dx, dy, pressure)
end

function loader.touchmoved(id, x, y, dx, dy, pressure)
    Game:touchmoved(id, x, y, dx, dy, pressure)
end

function loader.touchreleased(id, x, y, dx, dy, pressure)
    Game:touchreleased(id, x, y, dx, dy, pressure)
end

function loader.textinput(t)
    Game.textinput(t)
end

function loader.keypressed(key)
    Game.keypressed(key)
end

return loader