-- External Libraries
local Flux = require("Scripts.libraries.flux")

-- Helpers
local Constants = require ("Scripts.Constants")
local Timer = require("Scripts.Timer")

local Background = require("Scripts.Background")
local Character = require("Scripts.Character")
local AICharacter = require("Scripts.AICharacter")

-- Scenes
local PerformScene = require("Scripts.PerformScene")

local KeyboardUI = require("Scripts.UI.KeyboardUI")

local game = {

    Load = function(self)
		love.math.setRandomSeed(love.timer.getTime())
        love.graphics.setDefaultFilter("nearest", "nearest")

        self.gameState = Constants.GameStates.Perform
        
        self.background = Background:New()
        self.character = Character:New()
		self.AICharacter = AICharacter:New(true)
		self.AICharacter2 = AICharacter:New(false)

		KeyboardUI:Load()
		PerformScene:Load(KeyboardUI)
    end,

    Update = function(self, dt)
		Flux.update(dt)
        self:HandleInput()
        if self.gameState == Constants.GameStates.MainMenu then
            self.mainMenu:Update(dt)
            return
        elseif self.gameState == Constants.GameStates.Perform then
			PerformScene:Update(Flux, dt)
        elseif self.gameState == Constants.GameStates.Streets then
            self.background:Update(Flux, dt)
            self.character:Update(Flux, dt)
			self.AICharacter:Update(Flux, dt)
			self.AICharacter2:Update(Flux, dt)
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
            self.character:Draw()
			self.AICharacter:Draw()
			self.AICharacter2:Draw()
        end
    end,

	OnFanButtonClicked = function(self)
		self.deck:Fan()
	end,

	OnUnfanButtonClicked = function(self)
		self.deck:Unfan()
	end,

	OffsetCardButtonClicked = function(self)
		self.deck:OffsetRandomCard()
	end,

	OnGiveCardButtonClicked = function(self)
		self.deck:GiveSelectedCard()
	end,

    OnRetrieveCardButtonClicked = function(self)
		self.deck:RetrieveSelectedCard()
	end,

    OnGameStateChanged = function(self, newState)
        self.gameState = newState
    end,

    HandleInput = function(self)
        if love.keyboard.isDown("escape") then
            love.window.close()
        end
    end,
}
return game