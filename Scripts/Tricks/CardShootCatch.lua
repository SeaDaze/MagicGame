local Technique = require("Scripts.Techniques.Technique")
local Constants = require("Scripts.Constants")

local CardShootCatch = {
    New = function(self, deck, input, leftHand, rightHand, timer)
        local instance = setmetatable({}, self)

		-- Object references
        instance.deck = deck
        instance.input = input
		instance.leftHand = leftHand
		instance.rightHand = rightHand
		instance.timer = timer

		-- Variables
        instance.name = "card shoot"

        return instance
    end,

    OnStart = function(self)
		self.timerNotificationId = self.timer:AddListener(self, "OnTimerFinished")
		self.leftHand:ChangeState(Constants.LeftHandStates.MechanicsGrip)
        self.input:AddKeyListener("f", self.deck, "StartSpin")
		self.input:AddMouseListener(1, self.deck, "CatchCard")
		self.rightHand:ChangeState(Constants.RightHandStates.PalmDown)
		self.catchCardNotificationId = self.deck:AddListener("CatchCard", self, "OnCatchCard")
		self.dropCardNotificationId = self.deck:AddListener("OnCardDropped", self, "OnCardDropped")
    end,

    OnStop = function(self)
		self.input:RemoveKeyListener("f")
		self.input:RemoveMouseListener(1)
		self.deck:RemoveListener("CatchCard", self.catchCardNotificationId)
		self.deck:RemoveListener("OnCardDropped", self.dropCardNotificationId)
		self.deck:ResetSpinCard()
		self.timer:RemoveListener(self.timerNotificationId)
    end,

	OnTimerFinished = function(self, timerId)
		if timerId == "TurnOverCard" then
			self.rightHand:ChangeState(Constants.RightHandStates.PalmUpPinch)
			self.deck.cards[52]:ChangeState(Constants.CardStates.InRightHandPinchPalmUp)
		end
	end,

	OnCatchCard = function(self)
		print("OnCatchCard:")
		self.rightHand:ChangeState(Constants.RightHandStates.PalmDownPinch)
		self.timer:Start("TurnOverCard", 1)
		--self:SendToFinishListener()
	end,
	
	OnCardDropped = function(self)
		print("OnCardDropped:")
		--self:SendToFinishListener()
	end,
}

CardShootCatch.__index = CardShootCatch
setmetatable(CardShootCatch, Technique)
return CardShootCatch