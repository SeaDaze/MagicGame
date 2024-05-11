local Technique = require("Scripts.Techniques.Technique")
local Constants = require("Scripts.Constants")

local CardiniChange = {
    New = function(self, deck, input, leftHand, rightHand, timer, flux)
        local instance = setmetatable({}, self)

		-- Object references
        instance.deck = deck
        instance.input = input
		instance.leftHand = leftHand
		instance.rightHand = rightHand
		instance.timer = timer
		instance.flux = flux

		-- Variables
        instance.name = "cardini"

        return instance
    end,

    OnStart = function(self)
		self.timerNotificationId = self.timer:AddListener(self, "OnTimerFinished")
		self.leftHand:ChangeState(Constants.LeftHandStates.MechanicsGrip)
        self.input:AddKeyListener("f", self, "HandleChange")
		self.rightHand:ChangeState(Constants.RightHandStates.PalmDown)
    end,

    OnStop = function(self)
		self.input:RemoveKeyListener("f")
		self.timer:RemoveListener(self.timerNotificationId)
    end,

	OnTimerFinished = function(self, timerId)
		if timerId == "Halfway" then
			self.deck:CardiniChange()
			self.flux.to(self.deck.cards[1].scale, 1, { x = 5 } )
			self.flux.to(self.deck.cards[1].offset, 1, { x = 0 } )
			self.timer:Start("Finished", 1)
		end
	end,

	HandleChange = function(self)
		self.deck.cards[52].scale.x = 2
		--self.deck.cards[52].scale.y = 2.5
		self.deck.cards[52].offset = { x = 0, y = 3 }

		-- self.deck.cards[52].scale.x = 5
		-- self.deck.cards[52].offset = { x = 0, y = 0 }
		-- self.flux.to(self.deck.cards[52].scale, 1, { x = 0 } )
		-- self.flux.to(self.deck.cards[52].offset, 1, { x = -self.deck.cards[52].halfWidth * 5 } )
		-- self.timer:Start("Halfway", 1)
		--self.deck.cards[52].offset = { x = -self.deck.cards[52].halfWidth, y = 0 }
	end,

}

CardiniChange.__index = CardiniChange
setmetatable(CardiniChange, Technique)
return CardiniChange