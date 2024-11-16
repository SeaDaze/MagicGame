local Technique = require("Scripts.Techniques.Technique")
local Common = require("Scripts.Common")

local TableSpread = {
    New = function(self, deck, leftHand, rightHand)
        local instance = setmetatable({}, self)

        instance.deck = deck
		instance.leftHand = leftHand
        instance.rightHand = rightHand

		instance.name = "table spread"
        return instance
    end,

	Update = function(self, dt)
		if not self.pickingUp then
			return
		end
		local targetCard = self.deck:GetCard(self.targetPickUpCardIndex)
		if Common:DistanceSquared(targetCard.position.x, targetCard.position.y, self.leftHand.position.x, self.leftHand.position.y) < 50 then
			targetCard:SetState(GameConstants.CardStates.InLeftHand)

			local nextCard = self:FindNextPickupCard()
			if not nextCard then
				self.pickingUp = false
				self.leftHand:Enable()
				return
			end
			Flux.to(self.leftHand.position, 0.025, { x = self.deck:GetCard(self.targetPickUpCardIndex).position.x, y = self.deck:GetCard(self.targetPickUpCardIndex).position.y} )
		end
	end,

	FindNextPickupCard = function(self)
		while self.targetPickUpCardIndex < 53 do
			self.targetPickUpCardIndex = self.targetPickUpCardIndex + 1
			local nextCard = self.deck:GetCard(self.targetPickUpCardIndex)
			if nextCard and nextCard:GetState() == GameConstants.CardStates.Dropped then
				return nextCard
			elseif nextCard == nil then
				return nil
			end
		end
		return nil
	end,

    OnStart = function(self)
		self.timerNotificationId = Timer:AddListener(self, "OnTimerFinished")
		self.leftHand:SetState(GameConstants.HandStates.MechanicsGrip)
		self.deck:TableSpread()
		Input:AddMouseListener(1, self.deck, "SetLeftMouseButtonDown", "SetLeftMouseButtonUp")
		self.stopFanSpreadNotificationId = self.deck:AddListener("OnStopTableSpread", self, "OnStopTableSpread")
		self.rightHand:SetState(GameConstants.HandStates.PalmDownTableSpread)

		Input:AddKeyListener("space", self, "SwapHands")
    end,

    OnStop = function(self)
		self.deck:UnfanSpread()
		self.deck:RemoveListener("OnStopTableSpread", self.stopFanSpreadNotificationId)
		Input:RemoveMouseListener(1)
		Timer:RemoveListener(self.timerNotificationId)
    end,

	OnStopTableSpread = function(self, params)
		--print("OnStopFanSpread: ")
		HUD:SetScoreText(math.floor(params.quality))
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
			Timer:Start("UnfanSpread", 0.5)
		elseif timerId == "UnfanSpread" then
			self:PickUpCards()
			--self.deck:MoveSelectedCardToTop()
			--self.deck:UnfanSpread()
			--self.deck:RetrieveSelectedCard()
		-- 	Timer:Start("Reset", 0.35)
		-- elseif timerId == "Reset" then
		-- 	self.deck:ResetSelectedCard()
		end
	end,

	PickUpCards = function(self)
		self.leftHand:Disable()
		self.targetPickUpCardIndex = 0
		local firstCard = self:FindNextPickupCard()
		self.pickingUp = true
		Flux.to(self.leftHand.position, 0.5, { x = firstCard.position.x, y = firstCard.position.y} )
	end,

}

TableSpread.__index = TableSpread
setmetatable(TableSpread, Technique)
return TableSpread