local Technique = require("Scripts.Techniques.Technique")

local DoubleLift = {
    New = function(self, deck, leftHand, rightHand)
        local instance = setmetatable({}, self)

		-- Object references
        instance.deck = deck
		instance.leftHand = leftHand
		instance.rightHand = rightHand

		-- Variables
        instance.name = "double lift"
        return instance
    end,

    OnStart = function(self)
		self.timerNotificationId = Timer:AddListener(self, "OnTimerFinished")
		self.leftHand:SetState(GameConstants.HandStates.MechanicsGrip)
        Input:AddKeyListener("f", self.deck, "DoubleLift")
		self.rightHand:SetState(GameConstants.HandStates.PalmDown)
    end,

    OnStop = function(self)
		Input:RemoveKeyListener("f")
		Timer:RemoveListener(self.timerNotificationId)
    end,

	OnTimerFinished = function(self, timerId)
	end,
}

DoubleLift.__index = DoubleLift
setmetatable(DoubleLift, Technique)
return DoubleLift