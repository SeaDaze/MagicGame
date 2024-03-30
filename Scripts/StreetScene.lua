
local Constants = require ("Scripts.Constants")
local Character = require("Scripts.Character")
local AICharacterManager = require("Scripts.AICharacterManager")

local StreetScene =
{
    Load = function(self, gameInstance, keyboardUI, input)
		self.gameInstance = gameInstance
        self.keyboardUI = keyboardUI
		self.input = input

        self.playerCharacter = Character:New(gameInstance, keyboardUI)

        AICharacterManager:Load(self.playerCharacter)
    end,

	OnStart = function(self)
	end,

	OnStop = function(self)
	end,

    Update = function(self, Flux, dt)
        self.playerCharacter:Update(Flux, dt)
        AICharacterManager:Update(Flux, dt)
    end,

    Draw = function(self)
        self.playerCharacter:Draw()
        AICharacterManager:DrawAllCharacters()
    end,
}
return StreetScene