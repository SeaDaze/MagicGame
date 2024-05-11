local Technique = require("Scripts.Techniques.Technique")
local Constants = require("Scripts.Constants")

local DoubleLift = {
    New = function(self, deck, input, leftHand, rightHand, timer)
        local instance = setmetatable({}, self)

		-- Object references
        instance.deck = deck
        instance.input = input
		instance.leftHand = leftHand
		instance.rightHand = rightHand
		instance.timer = timer

		-- Variables
        instance.name = "double lift"

        return instance
    end,

    OnStart = function(self)
		self.timerNotificationId = self.timer:AddListener(self, "OnTimerFinished")
		self.leftHand:ChangeState(Constants.LeftHandStates.MechanicsGrip)
        self.input:AddKeyListener("f", self.deck, "DoubleLift")
		self.rightHand:ChangeState(Constants.RightHandStates.PalmDown)
    end,

    OnStop = function(self)
		self.input:RemoveKeyListener("f")
		self.timer:RemoveListener(self.timerNotificationId)
    end,

	OnTimerFinished = function(self, timerId)
	end,
}

DoubleLift.__index = DoubleLift
setmetatable(DoubleLift, Technique)
return DoubleLift