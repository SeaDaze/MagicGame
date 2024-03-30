-- External Libraries
local Flux = require("Scripts.libraries.flux")
local moonshine = require ("Scripts.libraries.moonshine")

-- Helpers
local Constants = require ("Scripts.Constants")
local Background = require("Scripts.Background")

-- Scenes
local PerformScene = require("Scripts.PerformScene")
local StreetScene = require("Scripts.StreetScene")

local HUD = require("Scripts.UI.HUD")
local KeyboardUI = require("Scripts.UI.KeyboardUI")


local Input = require("Scripts.Input")
local PlayerStats = require("Scripts.PlayerStats")

local game = {

    Load = function(self)
        love.math.setRandomSeed(love.timer.getTime())
        love.graphics.setDefaultFilter("nearest", "nearest")

        KeyboardUI:Load()
        self.gameState = Constants.GameStates.Streets
        
        self.background = Background:New()

        StreetScene:Load(self, KeyboardUI, Input)
		PerformScene:Load(self, KeyboardUI, Input)
        HUD:Load(PlayerStats)

        Input:AddKeyListener("escape", self, "ExitGame")
    end,

    Update = function(self, dt)
		Flux.update(dt)
        KeyboardUI:Update(Flux, dt)
        Input:Update()
        --HUD:Update()
        if self.gameState == Constants.GameStates.MainMenu then
            self.mainMenu:Update(dt)
            return
        elseif self.gameState == Constants.GameStates.Perform then
			PerformScene:Update(Flux, dt)
        elseif self.gameState == Constants.GameStates.Streets then
            StreetScene:Update(Flux, dt)
            self.background:Update(Flux, dt)
        end
    end,

    Draw = function(self)
        if self.gameState == Constants.GameStates.MainMenu then
            self.mainMenu:Draw()
        elseif self.gameState == Constants.GameStates.Perform then
			self.background:Draw()
			PerformScene:Draw()
        elseif self.gameState == Constants.GameStates.Streets then
            self.background:Draw()
            StreetScene:Draw()
        end
        KeyboardUI:Draw()
        HUD:Draw()
    end,

    OnGameStateChanged = function(self, newState)
        -- Handle Previous state
        if self.gameState == Constants.GameStates.Perform then
            PerformScene:OnStop()
        elseif self.gameState == Constants.GameStates.Streets then
            StreetScene:OnStop()
        end

        -- Change state
        self.gameState = newState

        -- New state
        if newState == Constants.GameStates.Perform then
            PerformScene:OnStart()
        elseif newState == Constants.GameStates.Streets then
            StreetScene:OnStart()
        end
    end,

    ExitGame = function(self)
        love.window.close()
    end,
}
return game