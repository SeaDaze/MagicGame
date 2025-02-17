local Technique = require("Scripts.Techniques.Technique")
local EventIds  = require("Scripts.System.EventIds")
local System = require("Scripts.System.System")
local BaseScript = require("Scripts.System.BaseScript")

local DuckChange = 
{
	Load = function(self, deck, leftHand, rightHand)
        self.deck = deck
		self.leftHand = leftHand
        self.rightHand = rightHand
		self.cardsToFlip = {
			deck:GetCard(52),
			deck:GetCard(51),
		}
	end,

	OnStart = function(self)
		self.leftHand:SetState(GameConstants.HandStates.MechanicsGrip)
		self.rightHand:SetState(GameConstants.HandStates.DuckChangeSqueeze)
	end,

	Update = function(self, dt)
		for _, card in ipairs(self.cardsToFlip) do
			card:SetPosition(self.rightHand:GetPosition())
		end
	end,

	FixedUpdate = function(self, dt)

	end,

}
return System:CreateChainedInheritanceScript(
	BaseScript,
	Technique,
	DuckChange
)
