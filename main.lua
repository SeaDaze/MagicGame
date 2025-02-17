local game = require("game")
local testEnvironment = require("Scripts.Test.TestEnvironment")
local testEnvironment2 = require("Scripts.Test.TestEnvironment2")

local mode = 2

local modes = {
    game,
    testEnvironment,
    testEnvironment2,
}

function love.load()
    modes[mode]:Load()
end

function love.update(dt)
    modes[mode]:Update(dt)
end

function love.draw()
    modes[mode]:Draw()
end