local game = require("game")

function love.load()
    game:Load()
end

function love.update(dt)
    game:Update(dt)
end

function love.draw()
    game:Draw()
	game:LateDraw()
end