-- Game objects
local RightHand = require("Scripts.RightHand")
local LeftHand = require("Scripts.LeftHand")
local Deck = require("Scripts.Deck")
--local ErdnaseChange = require("Scripts.Tricks.ErdnaseChange")
local Constants = require ("Scripts.Constants")

local PerformScene =
{
    Load = function(self, gameInstance, keyboardUI, input)
		self.gameInstance = gameInstance
        self.keyboardUI = keyboardUI
		self.leftHand = LeftHand.New()
        self.rightHand = RightHand.New()
		self.deck = Deck:New(self.leftHand, self.rightHand)
		self.input = input
    end,

	OnStart = function(self)
		self.input:AddKeyListener("f", self.deck, "FanSpread", "UnfanSpread" )
		self.input:AddKeyListener("tab", self, "ExitPerform")
		self.keyboardUI:AddKeyToUI("f", "FAN CARDS")
	end,

	OnStop = function(self)
		self.input:RemoveKeyListener("f")
		self.input:RemoveKeyListener("tab")
		self.keyboardUI:RemoveKeyFromUI("f")
	end,

    Update = function(self, Flux, dt)
		--self.erdnaseChange:Update(Flux, dt)
		self.deck:Update(Flux, dt)
		self.rightHand:FollowMouse(Flux)
		self.leftHand:HandleMovement(Flux, dt)
    end,

    Draw = function(self)
		self.leftHand:Draw()
		self.deck:Draw()
		self.rightHand:Draw()
    end,

	ExitPerform = function(self)
		self.gameInstance:OnGameStateChanged(Constants.GameStates.Streets)
	end,
}
return PerformScene