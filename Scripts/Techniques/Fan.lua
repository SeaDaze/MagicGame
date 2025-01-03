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

		instance.distanceThreshold = 20 * 20 * GameSettings.WindowResolutionScale

		instance.lastRotationAngle = 0
		instance.fanRotationPoint = 
		{
			x = 0,
			y = 0,
		}
        return instance
    end,

    OnStart = function(self)
		self.timerNotificationId = Timer:AddListener(self, "OnTimerFinished")
		self.leftHand:SetState(GameConstants.HandStates.Fan)
		self:InitializeFan()

		DrawSystem:AddDebugDraw(
            function ()
				love.graphics.setColor(1, 0, 0, 1)
				local cards = self.deck:GetCards()
				local sockets = {
					cards[52]:GetSprite():GetSocket("TopLeft"),
					cards[52]:GetSprite():GetSocket("Top"),
				}

				for _, socket in pairs(sockets) do
					love.graphics.ellipse(
						"fill",
						socket.x,
						socket.y,
						5,
						5,
						6
					)
				end
				
				love.graphics.setColor(1, 0, 1, 1)
				for _, point in pairs(self.points) do
					love.graphics.ellipse(
						"fill",
						point.x,
						point.y,
						3,
						3,
						6
					)
				end

				love.graphics.ellipse(
					"fill",
					self.fanRotationPoint.x,
					self.fanRotationPoint.y,
					3,
					3,
					6
				)

				love.graphics.setColor(1, 1, 1, 1)
            end
        )
    end,

    OnStop = function(self)
		self:UninitializeFan()
		Timer:RemoveListener(self.timerNotificationId)
    end,

	Update = function(self, dt)
		if self.fanSpreading then
			self:HandleFanRotation()
			self:EvaluateRightHandState()
		end
	end,

	FixedUpdate = function(self, dt)
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
			Timer:Start("InitializeFan", 1)
			
			--self:Technique_OnFinished()
		elseif timerId == "InitializeFan" then
			self:InitializeFan()
		elseif timerId == "Reset" then
			self.deck:ResetSelectedCard()
		end
	end,

	InitializeFan = function(self)
		local cards = self.deck:GetCards()
		for _, card in ipairs(cards) do
			card:SetTargetOriginOffsetRatio({ x = 0.5, y = 1 })
			card:SetState(GameConstants.CardStates.InLeftHandFanning)
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
			card:SetState(GameConstants.CardStates.InLeftHandDefault)
			card:SetTargetOriginOffsetRatio({ x = 0.5, y = 0.5 })
			card.targetAngle = 0
		end
		self.lastRotationAngle = 0
	end,

	HandleFanRotation = function(self)
		if not Input:GetRightActionDown() then
			return
		end
		local cards = self.deck:GetCards()
		local topCard = cards[52]
		local topCardSprite = topCard:GetSprite()
		local targetSocket = topCardSprite:GetSocket("TopLeft")
		local pointSocket = topCardSprite:GetSocket("Top")

		local topCardSpriteHeight = topCardSprite:GetHeight() * GameSettings.WindowResolutionScale
		local indexFingerPosition = self.rightHand:GetIndexFingerPosition()

		local socketOffset = {
			x = pointSocket.x - targetSocket.x,
			y = pointSocket.y - targetSocket.y,
		}

		local handsDistance = Common:DistanceSquared(targetSocket.x, targetSocket.y, indexFingerPosition.x, indexFingerPosition.y)
		if handsDistance > self.distanceThreshold then
			return
		end
		self.fanRotationPoint = {
			x = indexFingerPosition.x + socketOffset.x,
			y = indexFingerPosition.y + socketOffset.y
		}
		if self.fanRotationPoint.x < self.leftHand:GetPosition().x then
			return
		end

		local topCardPosition = topCardSprite:GetPosition()
		local v1 = { x = 0, y = -1 }
		local v2 = Common:Normalize({ x = self.fanRotationPoint.x - topCardPosition.x, y = self.fanRotationPoint.y - topCardPosition.y })
		local newAngle = Common:AngleBetweenVectors(v1, v2)

		if newAngle < self.lastRotationAngle then
			return
		end
		self.lastRotationAngle = newAngle

		for _, card in ipairs(self.spreadingCards) do
			local cardSprite = card:GetSprite()
			cardSprite.angle = newAngle
			card.targetAngle = newAngle
		end

		local lastPoint = self.points[self.pointIndex - 1]

		if lastPoint then
			local halfCircumference = math.pi * topCardSpriteHeight
			local distanceBetweenPoints =  halfCircumference / 52
			if Common:DistanceSquared(lastPoint.x, lastPoint.y, self.fanRotationPoint.x, self.fanRotationPoint.y) > distanceBetweenPoints * distanceBetweenPoints then
				self:CreateNewPoint(self.fanRotationPoint.x, self.fanRotationPoint.y)
			end
		else
			self:CreateNewPoint(self.fanRotationPoint.x, self.fanRotationPoint.y)
		end
	end,

	CreateNewPoint = function(self, x, y)
		self.points[self.pointIndex] = { x = x, y = y }
		self.pointIndex = self.pointIndex + 1

		table.insert(self.cardsInSpread, self.spreadingCards[1])
		local removedCard = table.remove(self.spreadingCards, 1)
		local lastCardAngle = removedCard:GetSprite():GetAngle()
		if lastCardAngle > 175 or table.isEmpty(self.spreadingCards) then
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
		local firstCardSprite = self.cardsInSpread[1]:GetSprite()
		local lastCardSprite = self.cardsInSpread[numberOfCardsInSpread]:GetSprite()
		local fullAngleQuality = (lastCardSprite.angle - firstCardSprite.angle) / 180 * 100
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
			local nextCard = self.cardsInSpread[cardIndex + 1]
			if nextCard then
				local cardSprite = card:GetSprite()
				local nextCardSprite = nextCard:GetSprite()
				local angleDiff = nextCardSprite.angle - cardSprite.angle
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
		local cards = self.deck:GetCards()
		local topCardSprite = cards[52]:GetSprite()
		local targetSocket = topCardSprite:GetSocket("TopLeft")

		local indexFingerPosition = self.rightHand:GetIndexFingerPosition()
		local withinThreshold = Common:DistanceSquared(targetSocket.x, targetSocket.y, indexFingerPosition.x, indexFingerPosition.y) <= self.distanceThreshold

		if not withinThreshold and self.leftHand:GetState() ~= GameConstants.HandStates.PalmDownNatural then
			self.rightHand:SetState(GameConstants.HandStates.PalmDownRelaxed)
		elseif withinThreshold and self.leftHand:GetState() ~= GameConstants.HandStates.PalmDownIndexOut then
			self.rightHand:SetState(GameConstants.HandStates.PalmDownRelaxedIndexOut)
		end
	end,
}

Fan.__index = Fan
setmetatable(Fan, Technique)
return Fan