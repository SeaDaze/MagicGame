local Technique = require("Scripts.Techniques.Technique")
local Constants = require("Scripts.Constants")

local Fan = {
    New = function(self, deck, input, leftHand, rightHand, timer, hud)
        local instance = setmetatable({}, self)

        instance.deck = deck
        instance.input = input
		instance.leftHand = leftHand
        instance.rightHand = rightHand
		instance.timer = timer
		instance.hud = hud

		instance.name = "fan"
        return instance
    end,

    OnStart = function(self)
		self.timerNotificationId = self.timer:AddListener(self, "OnTimerFinished")
		self.leftHand:ChangeState(Constants.LeftHandStates.Fan)
		self.deck:FanSpread()
		self.input:AddMouseListener(1, self.deck, "SetLeftMouseButtonDown", "SetLeftMouseButtonUp")
		self.stopFanSpreadNotificationId = self.deck:AddListener("OnStopFanSpread", self, "OnStopFanSpread")
		self.rightHand:ChangeState(Constants.RightHandStates.PalmDownIndexOut)
    end,

    OnStop = function(self)
		self.deck:UnfanSpread()
		self.deck:RemoveListener("OnStopFanSpread", self.stopFanSpreadNotificationId)
		self.input:RemoveMouseListener(1)
		self.timer:RemoveListener(self.timerNotificationId)
    end,

	OnStopFanSpread = function(self, params)
		--print("OnStopFanSpread: ")
		self.hud:SetScoreText(math.floor(params.quality))
		self.input:DisableForSeconds(7)
		self.timer:Start("SelectCard", 1)
	end,

	OnTimerFinished = function(self, timerId)
		--print("OnTimerFinished: timerId=", timerId)
		if timerId == "SelectCard" then
			self.deck:OffsetRandomCard()
			self.timer:Start("GiveCard", 1)
		elseif timerId == "GiveCard" then
			self.deck:GiveSelectedCard()
			self.timer:Start("UnfanSpread", 4)
		elseif timerId == "UnfanSpread" then
			self.deck:MoveSelectedCardToTop()
			self.deck:UnfanSpread()
			self.deck:RetrieveSelectedCard()
			self.timer:Start("Reset", 0.35)
		elseif timerId == "Reset" then
			self.deck:ResetSelectedCard()
		end
	end,

	EvaluateScore = function(self)

	end,
}

Fan.__index = Fan
setmetatable(Fan, Technique)
return Fan