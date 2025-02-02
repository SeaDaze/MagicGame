local game = require("game")
local testEnvironment = require("Scripts.Test.TestEnvironment")

function love.load()
    --game:Load()
	testEnvironment:Load()
end

function love.update(dt)
    --game:Update(dt)
	testEnvironment:Update(dt)
end

function love.draw()
    --game:Draw()
	testEnvironment:Draw()
end