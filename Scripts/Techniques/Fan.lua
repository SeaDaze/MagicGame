local Technique = require("Scripts.Techniques.Technique")

local Fan = {
    New = function(self, deck, leftHand, rightHand)
        local instance = setmetatable({}, self)

        instance.deck = deck
		instance.leftHand = leftHand
        instance.rightHand = rightHand

		instance.name = "fan"
        return instance
    end,

    OnStart = function(self)
		self.timerNotificationId = Timer:AddListener(self, "OnTimerFinished")
		self.leftHand:ChangeState(GameConstants.LeftHandStates.Fan)
		self.deck:FanSpread()
		Input:AddMouseListener(1, self.deck, "SetLeftMouseButtonDown", "SetLeftMouseButtonUp")
		self.stopFanSpreadNotificationId = self.deck:AddListener("OnStopFanSpread", self, "OnStopFanSpread")
		self.rightHand:ChangeState(GameConstants.RightHandStates.PalmDownIndexOut)
    end,

    OnStop = function(self)
		self.deck:UnfanSpread()
		self.deck:RemoveListener("OnStopFanSpread", self.stopFanSpreadNotificationId)
		Input:RemoveMouseListener(1)
		Timer:RemoveListener(self.timerNotificationId)
    end,

	OnStopFanSpread = function(self, params)
		self:Technique_OnTechniqueEvaluated(params.quality)
		HUD:SetScoreText(math.floor(params.quality))
		-- self.deck:UnfanSpread()
		-- self.deck:FanSpread()
		Input:DisableForSeconds(7)
		Timer:Start("SelectCard", 1)
	end,

	OnTimerFinished = function(self, timerId)
		--print("OnTimerFinished: timerId=", timerId)
		if timerId == "SelectCard" then
			self.deck:OffsetRandomCard()
			Timer:Start("GiveCard", 1)
		elseif timerId == "GiveCard" then
			self.deck:GiveSelectedCard()
			Timer:Start("UnfanSpread", 4)
		elseif timerId == "UnfanSpread" then
			self.deck:MoveSelectedCardToTop()
			self.deck:UnfanSpread()
			self.deck:RetrieveSelectedCard()
			Timer:Start("Reset", 0.35)
		elseif timerId == "Reset" then
			self.deck:ResetSelectedCard()
		end
	end,
}

Fan.__index = Fan
setmetatable(Fan, Technique)
return Fan