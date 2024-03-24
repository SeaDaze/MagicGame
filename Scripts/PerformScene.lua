-- Game objects
local RightHand = require("Scripts.RightHand")
local LeftHand = require("Scripts.LeftHand")
local Deck = require("Scripts.Deck")
--local ErdnaseChange = require("Scripts.Tricks.ErdnaseChange")
local Input = require("Scripts.Input")

local PerformScene =
{
    Load = function(self, keyboardUI)
        self.keyboardUI = keyboardUI
		self.leftHand = LeftHand.New()
        self.rightHand = RightHand.New()
		self.deck = Deck:New(self.leftHand)

		-- self.erdnaseChange = ErdnaseChange:New(self.leftHand, self.rightHand, self.deck)
		-- self.erdnaseChange:Start()

		self.keyboardUI:SetKeyText("f", "Fan Cards")
		Input:AddKeyListener("f", self.deck, "ToggleFan")
    end,

    Update = function(self, Flux, dt)
		--self.erdnaseChange:Update(Flux, dt)
		self.deck:Update(Flux, dt)
		self.rightHand:FollowMouse(Flux)
		self.leftHand:HandleMovement(Flux, dt)
		Input:Update()
    end,

    Draw = function(self)
		self.leftHand:Draw()
		self.deck:Draw()
		self.rightHand:Draw()
		self.keyboardUI:Draw()
    end,
}
return PerformScene