local Fonts = {}

function Fonts.load()
    Fonts.default = love.graphics.newFont("src/ui/fonts/font.otf", 16)
    Fonts.big = love.graphics.newFont("src/ui/fonts/font.otf", 24)
end

return Fonts