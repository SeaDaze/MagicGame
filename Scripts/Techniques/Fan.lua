local Technique = require("Scripts.Techniques.Technique")

local Fan = {
    New = function(self, deck, leftHand, rightHand)
        local instance = setmetatable({}, self)

        instance.deck = deck
		instance.leftHand = leftHand
        instance.rightHand = rightHand

		instance.name = "Fan"
		instance.points = {}
		instance.pointIndex = 1

		instance.cardSelection = false

        return instance
    end,

    OnStart = function(self)
		self.timerNotificationId = Timer:AddListener(self, "OnTimerFinished")
		self.leftHand:SetState(GameConstants.HandStates.Fan)
		self:InitializeFan()
    end,

    OnStop = function(self)
		self:UninitializeFan()
		Timer:RemoveListener(self.timerNotificationId)
    end,

	Update = function(self, dt)
	end,

	FixedUpdate = function(self, dt)
		if self.fanSpreading then
			self:EvaluateRightHandState()
			self:DuringFanSpread()
			self:HandleFanSpreadPoints()
		end
	end,

	Draw = function(self)
		for _, point in pairs(self.points) do
			love.graphics.setColor(1, 0.5, 0.5, 1)
			love.graphics.ellipse("fill", point.x, point.y, 3, 3, 6)
			love.graphics.setColor(1, 1, 1, 1)
        end
	end,

	OnCompleteFanSpread = function(self)
		self.rightHand:SetState(GameConstants.HandStates.PalmDownGrabOpen)
		self.fanSpreading = false
		local quality = self:EvaluateFanQuality()
		self:Technique_OnTechniqueEvaluated(quality)
		if self.cardSelection then
			Input:DisableForSeconds(7)
			Timer:Start("SelectCard", 1)
		else
			Input:DisableForSeconds(2)
			Timer:Start("UninitializeFan", 2)
		end
	end,

	OnTimerFinished = function(self, timerId)
		if timerId == "SelectCard" then
			self.deck:OffsetRandomCard()
			Timer:Start("GiveCard", 1)
		elseif timerId == "GiveCard" then
			self.deck:GiveSelectedCard()
			Timer:Start("UninitializeFan", 4)
		elseif timerId == "UninitializeFan" then
			if self.cardSelection then
				self.deck:MoveSelectedCardToTop()
				self.deck:RetrieveSelectedCard()
				Timer:Start("Reset", 0.35)
			end
			self:UninitializeFan()
			self:Technique_OnFinished()
		elseif timerId == "Reset" then
			self.deck:ResetSelectedCard()
		end
	end,

	InitializeFan = function(self)
		local cards = self.deck:GetCards()
		for _, card in ipairs(cards) do
			card.targetOriginOffset = { x = 0, y = card.halfHeight }
			card.previousOriginOffset = { x = 0, y = card.halfHeight }
		end
		self.fanSpreading = true
		self.spreadingCards = {}
		self.cardsInSpread = {}
		for index, card in ipairs(cards) do
			self.spreadingCards[index] = card
		end
	end,

	UninitializeFan = function(self)
		local cards = self.deck:GetCards()
		for _, card in ipairs(cards) do
			card.targetOriginOffset = { x = 0, y = 0 }
			card.previousOriginOffset = { x = 0, y = 0 }
			card.targetAngle = 0
		end
	end,

	DuringFanSpread = function(self)
		local numberOfPoints = table.count(self.points)
		if numberOfPoints == 0 then
			return
		end
		local targetPoint = self.points[numberOfPoints]
		if not targetPoint then
			return
		end
		if self.rightHand.position.x < self.leftHand.position.x then
			return
		end
		for _, card in ipairs(self.spreadingCards) do
			local v2 = Common:Normalize({ x = targetPoint.x - card.position.x, y = targetPoint.y - card.position.y })
			local v1 = { x = 0, y = -1 }
			local newAngle = Common:AngleBetweenVectors(v1, v2)
			local angleDelta = (newAngle - card.targetAngle)
			card.targetAngle = (card.targetAngle + angleDelta) * 2
		end
	end,

	HandleFanSpreadPoints = function(self)
		if not Input:GetRightActionDown() then
			return
		end
		local leftHandPosition = self.leftHand.position
		local indexFingerPosition = self.rightHand:GetIndexFingerPosition()

		local handsDistance = Common:DistanceSquared(leftHandPosition.x, leftHandPosition.y, indexFingerPosition.x, indexFingerPosition.y)
		if handsDistance > 20000 then
			return
		end
		if indexFingerPosition.x < leftHandPosition.x then
			return
		end
		self:CreateNewPoint(indexFingerPosition.x, indexFingerPosition.y)
	end,

	CreateNewPoint = function(self, x, y)
		if table.isEmpty(self.points) then
			self.points[self.pointIndex] = { x = x, y = y }
			return
		end
		local lastPoint = self.points[self.pointIndex]
		if Common:DistanceSquared(lastPoint.x, lastPoint.y, x, y) > 30 then
			self.pointIndex = self.pointIndex + 1
			self.points[self.pointIndex] = { x = x, y = y }
			self:OnNewPointCreated()
		end
	end,

	OnNewPointCreated = function(self)
		table.insert(self.cardsInSpread, self.spreadingCards[1])
		local removedCard = table.remove(self.spreadingCards, 1)
		if removedCard and self.tableSpreading then
			removedCard:SetState(GameConstants.CardStates.Dropped)
		end
		if table.isEmpty(self.spreadingCards) then
			self.points = {}
			self.pointIndex = 1
			self:OnCompleteFanSpread()
		end
	end,

	EvaluateFanQuality = function(self)
		local numberOfCardsInSpread = table.count(self.cardsInSpread)
		if numberOfCardsInSpread <= 0 then
			return
		end
		local angleDistributionQuality = self:EvaluateCardAngleDistribution()
		local cardNumberQuality = (numberOfCardsInSpread / 52) * 100
		local fullAngleQuality = (self.cardsInSpread[numberOfCardsInSpread].angle - self.cardsInSpread[1].angle) / 180 * 100
		local finalEvaluation = (angleDistributionQuality + cardNumberQuality + fullAngleQuality) / 3
		finalEvaluation = finalEvaluation + 5
		finalEvaluation = (finalEvaluation * finalEvaluation) / 100
		return Common:Clamp(finalEvaluation, 0, 100)
	end,

	EvaluateCardAngleDistribution = function(self)
		local targetAngleDiff = 180 / table.count(self.cardsInSpread)

		local angleDiffPercentages = {}
		local cardIndex = 1
		local totalDiff = 0

		for _, card in ipairs(self.cardsInSpread) do
			if self.cardsInSpread[cardIndex + 1] then
				local angleDiff = self.cardsInSpread[cardIndex + 1].angle - card.angle
				local calculatedAngleDistribution = (angleDiff / targetAngleDiff) * 100
				if calculatedAngleDistribution > 100 then
					local overEstimation = calculatedAngleDistribution - 100
					calculatedAngleDistribution = 100 - overEstimation
				end
				table.insert(angleDiffPercentages, calculatedAngleDistribution)
				totalDiff = totalDiff + calculatedAngleDistribution
				cardIndex = cardIndex + 1
			end
		end

		return totalDiff / table.count(angleDiffPercentages)
	end,
	
	EvaluateRightHandState = function(self)
		local leftHandPosition = self.leftHand.position
		local indexFingerPosition = self.rightHand:GetIndexFingerPosition()
	
		local handsDistance = Common:DistanceSquared(leftHandPosition.x, leftHandPosition.y, indexFingerPosition.x, indexFingerPosition.y)

		if handsDistance > 20000 and self.leftHand:GetState() ~= GameConstants.HandStates.PalmDownNatural or indexFingerPosition.x < leftHandPosition.x  then
			self.rightHand:SetState(GameConstants.HandStates.PalmDownGrabOpen)
		elseif handsDistance <= 20000 and self.leftHand:GetState() ~= GameConstants.HandStates.PalmDownIndexOut and indexFingerPosition.x > leftHandPosition.x then
			self.rightHand:SetState(GameConstants.HandStates.PalmDownIndexOut)
		end
	end,
}

Fan.__index = Fan
setmetatable(Fan, Technique)
return Fan