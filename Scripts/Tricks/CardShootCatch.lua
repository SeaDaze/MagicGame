local Technique = require("Scripts.Techniques.Technique")

local CardShootCatch = {
    New = function(self, deck, leftHand, rightHand, timer)
        local instance = setmetatable({}, self)

		-- Object references
        instance.deck = deck
		instance.leftHand = leftHand
		instance.rightHand = rightHand
		instance.timer = timer

		-- Variables
        instance.name = "card shoot"

        return instance
    end,

    OnStart = function(self)
		self.timerNotificationId = Timer:AddListener(self, "OnTimerFinished")
		self.leftHand:SetState(GameConstants.HandStates.MechanicsGrip)
        --Input:AddKeyListener("f", self.deck, nil, "StartSpin")
		--Input:AddMouseListener(1, self.deck, "CatchCard")
		self.rightHand:SetState(GameConstants.HandStates.PalmDown)
		self.catchCardNotificationId = self.deck:AddListener("CatchCard", self, "OnCatchCard")
		self.dropCardNotificationId = self.deck:AddListener("OnCardDropped", self, "OnCardDropped")
    end,

    OnStop = function(self)
		--Input:RemoveKeyListener("f")
		--Input:RemoveMouseListener(1)
		self.deck:RemoveListener("CatchCard", self.catchCardNotificationId)
		self.deck:RemoveListener("OnCardDropped", self.dropCardNotificationId)
		self.deck:ResetSpinCard()
		Timer:RemoveListener(self.timerNotificationId)
    end,

	OnTimerFinished = function(self, timerId)
		if timerId == "TurnOverCard" then
			self.rightHand:SetState(GameConstants.HandStates.PalmUpPinch)
			self.deck.cards[52]:SetState(GameConstants.CardStates.InRightHandPinchPalmUp)
		end
	end,

	OnCatchCard = function(self)
		print("OnCatchCard:")
		self.rightHand:SetState(GameConstants.HandStates.PalmDownPinch)
		Timer:Start("TurnOverCard", 1)
	end,
	
	OnCardDropped = function(self)
		print("OnCardDropped:")
	end,
}

CardShootCatch.__index = CardShootCatch
setmetatable(CardShootCatch, Technique)
return CardShootCatch