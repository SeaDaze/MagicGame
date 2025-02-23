local Technique = require("Scripts.Techniques.Technique")
local EventIds  = require("Scripts.System.EventIds")
local System = require("Scripts.System.System")
local BaseScript = require("Scripts.System.BaseScript")

local Fan = {
	Load = function(self, deck, leftHand, rightHand)
        self.deck = deck
		self.leftHand = leftHand
        self.rightHand = rightHand
		self.points = {}
		self.pointIndex = 1
		self.cardSelection = false
		self.lastRotationAngle = 0
		self.newPoint = 
		{
			x = 0,
			y = 0,
		}
		self.spreadSFX = AudioSystem:GetAudioSourceClone("Audio/Cards/Sound_Fan_3.mp3")
	end,

    OnStart = function(self)
		Log.Med("OnStart: Fan Technique")
		self.timerNotificationId = Timer:AddListener(self, "OnTimerFinished")
		self.leftHand:SetState(GameConstants.HandStates.Fan)
		self:InitializeFan()

		self.rightActionNotificationId = EventSystem:ConnectToEvent(EventIds.RightAction, self, "OnInputAction")

		-- DrawSystem:AddDebugDraw(
        --     function ()
		-- 		local indexFingerPosition = self.rightHand:GetIndexFingerPosition()
		-- 		love.graphics.ellipse(
		-- 			"fill",
		-- 			indexFingerPosition.x,
		-- 			indexFingerPosition.y,
		-- 			3,
		-- 			3,
		-- 			6
		-- 		)
		-- 	end
		-- )

		-- DrawSystem:AddDebugDraw(
        --     function ()
		-- 		love.graphics.setColor(1, 0, 0, 1)
				-- local cards = self.deck:GetCards()
				-- local sockets = {
				-- 	cards[52]:GetSprite():GetSocket("TopLeft"),
				-- 	cards[52]:GetSprite():GetSocket("Top"),
				-- }

				-- for _, socket in pairs(sockets) do
				-- 	love.graphics.ellipse(
				-- 		"fill",
				-- 		socket.x,
				-- 		socket.y,
				-- 		5,
				-- 		5,
				-- 		6
				-- 	)
				-- end
				
				-- love.graphics.setColor(1, 0, 1, 1)
				-- for _, point in pairs(self.points) do
				-- 	love.graphics.ellipse(
				-- 		"fill",
				-- 		point.x,
				-- 		point.y,
				-- 		3,
				-- 		3,
				-- 		6
				-- 	)
				-- end

				-- love.graphics.ellipse(
				-- 	"fill",
				-- 	self.newPoint.x,
				-- 	self.newPoint.y,
				-- 	3,
				-- 	3,
				-- 	6
				-- )
				
			-- 	local cards = self.deck:GetCards()
			-- 	local topCard = cards[52]
			-- 	local topCardSprite = topCard:GetSprite()
			-- 	local top = topCardSprite:GetSocket("TopLeft")
			-- 	local bottom = topCardSprite:GetSocket("BottomLeft")
			-- 	local indexFingerPosition = self.rightHand:GetIndexFingerPosition()

			-- 	love.graphics.ellipse(
			-- 		"fill",
			-- 		indexFingerPosition.x,
			-- 		indexFingerPosition.y,
			-- 		3,
			-- 		3,
			-- 		6
			-- 	)

			-- 	love.graphics.line(top.x, top.y, bottom.x, bottom.y)
			-- 	love.graphics.line(indexFingerPosition.x, indexFingerPosition.y, bottom.x, bottom.y)
			-- 	love.graphics.line(top.x, top.y, indexFingerPosition.x, indexFingerPosition.y)

			-- 	local a = topCardSprite:GetHeight() * GameSettings.WindowResolutionScale
			-- 	local b = Common:Distance(bottom.x, bottom.y, indexFingerPosition.x, indexFingerPosition.y)
			-- 	local c = Common:Distance(indexFingerPosition.x, indexFingerPosition.y, top.x, top.y)
			-- 	local altitude = Common:CalculateTriangleAltitude(a, b, c)
			-- 	local internalAngleA = Common:CalculateTriangleInternalAngle(c, a, b)
			-- 	local internalAngleB = Common:CalculateTriangleInternalAngle(b, c, a)

			-- 	local direction = Common:ConvertAngleToVectorDirection(topCardSprite:GetAngle())
			-- 	direction = Common:Normalize(direction)

			-- 	local altitudePoint = {
			-- 		x = indexFingerPosition.x + (-direction.x * altitude),
			-- 		y = indexFingerPosition.y + (-direction.y * altitude),
			-- 	}
			-- 	if internalAngleA < 90 and internalAngleB < 90 then
			-- 		love.graphics.setColor(0, 1, 0, 1)
			-- 	else
			-- 		love.graphics.setColor(1, 0, 0, 1)
			-- 	end

			-- 	love.graphics.line(indexFingerPosition.x, indexFingerPosition.y, altitudePoint.x, altitudePoint.y)
			-- 	love.graphics.setColor(1, 1, 1, 1)
            -- end
        --)
    end,

    OnStop = function(self)
		Log.Med("OnStop: Fan Technique")
		Timer:RemoveListener(self.timerNotificationId)
    end,

	FixedUpdate = function(self, dt)
		if self.fanSpreading then
			self:HandleFanRotation()
			self:EvaluateRightHandState()
		end
	end,

	OnCompleteFanSpread = function(self)
		self.rightHand:SetState(GameConstants.HandStates.PalmDownGrabOpen)
		self.fanSpreading = false
		local quality = self:EvaluateFanQuality()
		EventSystem:BroadcastEvent(EventIds.TechniqueEvaluated, "fan", quality)
		if self.cardSelection then
			Timer:Start("SelectCard", 1)
		else
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
			else
				self:UninitializeFan()
				Timer:Start("Finish", 0.5)
			end
		elseif timerId == "Finish" then
			EventSystem:BroadcastEvent(EventIds.PlayerTechniqueFinished)
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

	OnInputAction = function(self, action, pressed)
		self.rightActionPressed = pressed
	end,

	HandleFanRotation = function(self)
		if not self.rightActionPressed then
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

		local touchingEdge = self:EvaluateTouchingEdge()

		if not touchingEdge then
			return
		end
		self.newPoint = {
			x = indexFingerPosition.x + socketOffset.x,
			y = indexFingerPosition.y + socketOffset.y
		}
		if self.newPoint.x < self.leftHand:GetPosition().x then
			return
		end
		
		local topCardPosition = topCardSprite:GetPosition()
		local v1 = { x = 0, y = -1 }
		local v2 = Common:Normalize({ x = self.newPoint.x - topCardPosition.x, y = self.newPoint.y - topCardPosition.y })
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
			if Common:DistanceSquared(lastPoint.x, lastPoint.y, self.newPoint.x, self.newPoint.y) > distanceBetweenPoints * distanceBetweenPoints then
				self:CreateNewPoint(self.newPoint.x, self.newPoint.y)
			end
		else
			self:CreateNewPoint(self.newPoint.x, self.newPoint.y)
		end
	end,

	CreateNewPoint = function(self, x, y)
		self.points[self.pointIndex] = { x = x, y = y }
		self.pointIndex = self.pointIndex + 1

		table.insert(self.cardsInSpread, self.spreadingCards[1])
		local removedCard = table.remove(self.spreadingCards, 1)
		local lastCardAngle = removedCard:GetSprite():GetAngle()

		-- local pitch = 1 + (self.pointIndex / 52)
		-- removedCard.fanSuccessSFX:setPitch(pitch)
		-- AudioSystem:PlaySound(removedCard.fanSuccessSFX)
		-- AudioSystem:PlaySound(removedCard.fanSpreadSFX)

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
		if finalEvaluation ~= finalEvaluation then
			return 0
		end
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

	EvaluateTouchingEdge = function(self)
		local cards = self.deck:GetCards()
		local topCardSprite = cards[52]:GetSprite()
		local top = topCardSprite:GetSocket("TopLeft")
		local bottom = topCardSprite:GetSocket("BottomLeft")
		local indexFingerPosition = self.rightHand:GetIndexFingerPosition()

		local a = topCardSprite:GetHeight() * GameSettings.WindowResolutionScale
		local b = Common:Distance(bottom.x, bottom.y, indexFingerPosition.x, indexFingerPosition.y)
		local c = Common:Distance(indexFingerPosition.x, indexFingerPosition.y, top.x, top.y)
		local altitude = Common:CalculateTriangleAltitude(a, b, c)
		local internalAngleA = Common:CalculateTriangleInternalAngle(c, a, b)
		local internalAngleB = Common:CalculateTriangleInternalAngle(b, c, a)

		local direction = Common:ConvertAngleToVectorDirection(topCardSprite:GetAngle())
		direction = Common:Normalize(direction)

		if internalAngleA < 90 and internalAngleB < 90 and altitude < 20 then
			return true
		end
		return false
	end,

	EvaluateRightHandState = function(self)
		local touchingEdge = self:EvaluateTouchingEdge()
		if not touchingEdge and self.rightHand:GetState() ~= GameConstants.HandStates.PalmDownRelaxed then
			self.rightHand:SetState(GameConstants.HandStates.PalmDownRelaxed)
		else
			if not touchingEdge then
				return
			end
			if self.rightActionPressed then
				if self.rightHand:GetState() ~= GameConstants.HandStates.PalmDownRelaxedIndexPressed then
					self.rightHand:SetState(GameConstants.HandStates.PalmDownRelaxedIndexPressed)
				end
			else
				if self.rightHand:GetState() ~= GameConstants.HandStates.PalmDownRelaxedIndexOut then
					self.rightHand:SetState(GameConstants.HandStates.PalmDownRelaxedIndexOut)
				end
			end

		end
	end,
}
return System:CreateChainedInheritanceScript(
	BaseScript,
	Technique,
	Fan
)