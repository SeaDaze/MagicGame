local game = require("game")

-- Load some default values for our rectangle.
function love.load()
    game:Load()
end

-- Increase the size of the rectangle every frame.
function love.update(dt)
    game:Update(dt)
end

function love.draw()
    game:Draw()
	game:LateDraw()
end