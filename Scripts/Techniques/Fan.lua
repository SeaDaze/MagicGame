local Technique = require("Scripts.Techniques.Technique")

local Fan = {
    New = function(self, deck, input, timer)
        local instance = setmetatable({}, self)

        instance.deck = deck
        instance.input = input
        instance.name = "fan"
		instance.timer = timer
        return instance
    end,

    OnStart = function(self)
		self.timerNotificationId = self.timer:AddListener(self, "OnTimerFinished")
		self.deck:FanSpread()
		self.input:AddMouseListener(1, self.deck, "SetLeftMouseButtonDown", "SetLeftMouseButtonUp")
		self.stopFanSpreadNotificationId = self.deck:AddListener("OnStopFanSpread", self, "OnStopFanSpread")
    end,

    OnStop = function(self)
		self.deck:UnfanSpread()
		self.deck:RemoveListener("OnStopFanSpread", self.stopFanSpreadNotificationId)
		self.input:RemoveMouseListener(1)
		self.timer:RemoveListener(self.timerNotificationId)
    end,

	OnStopFanSpread = function(self)
		print("OnStopFanSpread: ")
		self.input:DisableForSeconds(8)
		self.timer:Start("SelectCard", 1)
	end,

	OnTimerFinished = function(self, timerId)
		print("OnTimerFinished: timerId=", timerId)
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
}

Fan.__index = Fan
setmetatable(Fan, Technique)
return Fan