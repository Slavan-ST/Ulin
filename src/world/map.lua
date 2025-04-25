local Map = {}

function Map.draw()
    love.graphics.setColor(0.15, 0.15, 0.15)
    love.graphics.rectangle("fill", 0, 0, 2000, 2000) -- большая "земля"
end

return Map