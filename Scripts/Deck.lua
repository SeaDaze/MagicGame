local Common = require("Scripts.Common")
local PlayingCard = require ("Scripts.PlayingCard")

local Deck = {
	New = function(self, leftHand, rightHand)
		local instance = setmetatable({}, self)
		instance.cards = {}
		instance.fannedCards = 0
		instance.offsetCardIndex = nil
		instance.leftHand = leftHand
		instance.rightHand = rightHand
		instance.visible = true
		instance.cards = {}
        instance.clubs = {}
        instance.hearts = {}
        instance.diamonds = {}
        instance.spades = {}

		instance.lines = {}
        instance.lineIndex = 1

		local cardSpritesheet = love.graphics.newImage("Images/Cards/cardSpritesheet.png")
		local cardWidth = 18
		local cardHeight = 24
		local spritesheetWidth = cardSpritesheet:getWidth()
        local spritesheetHeight = cardSpritesheet:getHeight()
		local faceDownSprite = love.graphics.newImage("Images/Cards/cardBack_01.png")

		local x = 0
        for cardValue = 1, 13 do
            local clubQuad = love.graphics.newQuad(x, 0, cardWidth, cardHeight, spritesheetWidth, spritesheetHeight)
			instance.clubs[cardValue] = PlayingCard:New(
				cardValue,
				GameConstants.CardSuits.Clubs,
				cardSpritesheet,
				clubQuad,
				nil,
				faceDownSprite,
				leftHand,
				rightHand
			)
			instance.cards[cardValue] = instance.clubs[cardValue]

			local diamondQuad = love.graphics.newQuad(x, cardHeight, cardWidth, cardHeight, spritesheetWidth, spritesheetHeight)
			instance.diamonds[cardValue] = PlayingCard:New(
				cardValue,
				GameConstants.CardSuits.Diamonds,
				cardSpritesheet,
				diamondQuad,
				nil,
				faceDownSprite,
				leftHand,
				rightHand
			)
			instance.cards[cardValue + 13] = instance.diamonds[cardValue]

			local heartQuad = love.graphics.newQuad(x, cardHeight * 2, cardWidth, cardHeight, spritesheetWidth, spritesheetHeight)
			instance.hearts[cardValue] = PlayingCard:New(
				cardValue,
				GameConstants.CardSuits.Hearts,
				cardSpritesheet,
				heartQuad,
				nil,
				faceDownSprite,
				leftHand,
				rightHand
			)
			instance.cards[cardValue + 26] = instance.hearts[cardValue]

			local spadeQuad = love.graphics.newQuad(x, cardHeight * 3, cardWidth, cardHeight, spritesheetWidth, spritesheetHeight)
			instance.spades[cardValue] = PlayingCard:New(
				cardValue,
				GameConstants.CardSuits.Spades,
				cardSpritesheet,
				spadeQuad,
				nil,
				faceDownSprite,
				leftHand,
				rightHand
			)
			instance.cards[cardValue + 39] = instance.spades[cardValue]
			
            x = x + cardWidth
        end

		instance.notificationListeners = {}
		instance.listenerId = 0
		return instance
	end,

	Update = function(self, dt)
		for _, card in ipairs(self.cards) do
			card:Update(dt)
			if not card:GetDropped() and (card:GetPosition().x < 0 or card:GetPosition().x > love.graphics.getWidth() or card:GetPosition().y < 0 or card:GetPosition().y > love.graphics.getHeight()) then
				card:SetDropped(true)
				self:OnCardDropped(card)
			end
		end
	end,

	FixedUpdate = function(self, dt)
		if self.tableSpreading then
			self:HandleTableSpreadLines()
		end
	end,

	Draw = function(self)
		if not self.visible then
			return
		end
		for _, card in ipairs(self.cards) do
			card:Draw()
		end

		for _, line in pairs(self.lines) do
            love.graphics.line(line.x1, line.y1, line.x2, line.y2)
        end
    end,

	HandleTableSpreadLines = function(self)
		if self.startedTableSpread and not self.leftMouseDown then
			if self.originPoint then
				self.originPoint = nil
			end
			self.lines = {}
			self.lineIndex = 1
			self.startedTableSpread = false
			self:OnStopTableSpread()
			return
		end

		local rightHandPosition = self.rightHand:GetPosition()

		if self.leftMouseDown then
			if not self.lines[self.lineIndex] then
				if Common:TableCount(self.lines) == 0 then
					self.startedTableSpread = true
					self:OnStartTableSpread()
				end
				local x = rightHandPosition.x
				local y = rightHandPosition.y
				if self.lines[self.lineIndex - 1] then
					x = self.lines[self.lineIndex - 1].x2
					y = self.lines[self.lineIndex - 1].y2
				end
				self.lines[self.lineIndex] = { x1 = x, y1 = y, x2 = x, y2 = y }
			end
			self.lines[self.lineIndex].x2 = rightHandPosition.x
			self.lines[self.lineIndex].y2 = rightHandPosition.y
			if Common:DistanceSquared(self.lines[self.lineIndex].x1, self.lines[self.lineIndex].y1, self.lines[self.lineIndex].x2, self.lines[self.lineIndex].y2) > 30 then
				self.lineIndex = self.lineIndex + 1
				self:OnNewLineCreated(self.lineIndex)
			end
		end
	end,

	GiveSelectedCard = function(self)
		if self.offsetCardIndex then
			self.cards[self.offsetCardIndex]:SetState(GameConstants.CardStates.HeldBySpectator)
		end
	end,

	RetrieveSelectedCard = function(self)
		if self.offsetCardIndex then
			self.cards[self.offsetCardIndex]:SetState(GameConstants.CardStates.ReturningToDeck)
		end
	end,

	-----------------------------------------------------------------------------------------------------------
	-- SECTION Helpers
	-----------------------------------------------------------------------------------------------------------

	Swap = function(self, a, b)
		if a < 1 or a > 52 then
			return
		end
		if b < 1 or b > 52 then
			return
		end
		if a == b then
			return
		end
		local temp = self.cards[a]
		self.cards[a] = self.cards[b]
		self.cards[b] = temp
	end,

	---@param self any
	---@param a number index of element to move
	---@param b number newIndex
	MoveToPosition = function(self, a, b)
		table.insert(self.cards, b, table.remove(self.cards, a))
	end,

	FlipDeck = function(self)
		local reversed = {}
		for i = 52, 1, -1 do
			self.cards[i]:Flip()
			table.insert(reversed, self.cards[i])
		end
		self.cards = reversed
	end,

	Shuffle = function(self)
		local shuffledDeck = {}
		for cardNumber = 1, 52 do
			local cardCount = Common:TableCount(self.cards)
			local randomIndex = math.random(1, cardCount)
			table.insert(shuffledDeck, self.cards[randomIndex])
			table.remove(self.cards, randomIndex)
		end
		self.cards = shuffledDeck
	end,

	OffsetCard = function(self, cardIndex)
		-- if self.fannedCards == 0 then
		-- 	return
		-- end
		if self.offsetCardIndex then
			self:UnoffsetCard(self.offsetCardIndex)
		end
		self.cards[cardIndex].previousOriginOffset = { x = self.cards[cardIndex].originOffset.x, y = self.cards[cardIndex].originOffset.y }
		self.cards[cardIndex].targetOriginOffset = { x = 0, y = self.cards[cardIndex].originOffset.y + self.cards[cardIndex].halfHeight }
		self.offsetCardIndex = cardIndex
	end,
	
	UnoffsetCard = function(self, cardIndex)
		self.cards[cardIndex].targetOriginOffset = { x = self.cards[cardIndex].previousOriginOffset.x, y = self.cards[cardIndex].previousOriginOffset.y }
		self.offsetCardIndex = nil
	end,

	OffsetRandomCard = function(self)
		local randomCardIndex = love.math.random(1, 52)
		self:OffsetCard(randomCardIndex)
	end,

	MoveSelectedCardToTop = function(self)
		if not self.offsetCardIndex then
			return
		end
		self:MoveToPosition(self.offsetCardIndex, 52)
		self.offsetCardIndex = 52
	end,

	ResetSelectedCard = function(self)
		if not self.offsetCardIndex then
			return
		end
		self.cards[self.offsetCardIndex]:SetState(GameConstants.CardStates.InLeftHand)
	end,

	EvaluateTableSpreadQuality = function(self)
		local numberOfCardsInSpread = Common:TableCount(self.cardsInSpread)

		local totalDistance = 0
		local distances = {}
		for cardIndex, card in ipairs(self.cardsInSpread) do
			local nextCard = self.cardsInSpread[cardIndex + 1]
			if nextCard then
				local distanceSquared = Common:DistanceSquared(card.position.x, card.position.y, nextCard.position.x, nextCard.position.y)
				totalDistance = totalDistance + distanceSquared
				table.insert(distances, distanceSquared)
			end
		end

		local averageDistance = totalDistance / numberOfCardsInSpread

		local distanceDiffScore = 0
		for _, distanceDiff in ipairs(distances) do
			local calculatedDistanceDistribution = (distanceDiff / averageDistance) * 100
			if calculatedDistanceDistribution > 100 then
				local overEstimation = calculatedDistanceDistribution - 100
				calculatedDistanceDistribution = 100 - overEstimation
			end
			distanceDiffScore = distanceDiffScore + calculatedDistanceDistribution
		end

		distanceDiffScore = distanceDiffScore / Common:TableCount(distances)

		local cardNumberQuality = (numberOfCardsInSpread / 52) * 100
		local finalScore = (cardNumberQuality + distanceDiffScore) / 2

		return finalScore
	end,

	SwapHands = function(self)
		for _, card in ipairs(self.cards) do
			if card:GetState() == GameConstants.CardStates.InLeftHand then
				card:SetState(GameConstants.CardStates.InRightHandTableSpread)
			elseif card:GetState() == GameConstants.CardStates.InRightHandTableSpread then
				card:SetState(GameConstants.CardStates.InLeftHand)
			end
		end
	end,
	-----------------------------------------------------------------------------------------------------------
	-- !SECTION
	-- SECTION Techniques
	-----------------------------------------------------------------------------------------------------------

	Fan = function(self)
		local angleIncrement = 8
		local angle = 0
		self.fannedCards = 0
		for _, card in ipairs(self.cards) do
			card.targetOriginOffset = { x = 0, y = card.halfHeight }
			card.previousOriginOffset = { x = 0, y = card.halfHeight }
			card.targetAngle = angle
			if angle < 180 then
				angle = angle + angleIncrement
				self.fannedCards = self.fannedCards + 1
			end
		end
	end,

	OnStartTableSpread = function(self)
		self.tableSpreading = true
	end,

	OnStopTableSpread = function(self)
		self:BroadcastToListeners("OnStopTableSpread", { quality = self:EvaluateTableSpreadQuality() })
	end,

	TableSpread = function(self)
		for _, card in ipairs(self.cards) do
			card:SetState(GameConstants.CardStates.InRightHandTableSpread)
		end
		self.tableSpreading = true
		self.spreadingCards = {}
		self.cardsInSpread = {}
		for index, card in ipairs(self.cards) do
			self.spreadingCards[index] = card
		end
	end,

	SingleLift = function(self)
		self.cards[52]:Flip()
	end,

	DoubleLift = function(self)
		-- We swap the cards here because the second top card goes to the top when they are both flipped over together
		self:Swap(51, 52)
		self.cards[51]:Flip()
		self.cards[52]:Flip()
	end,

	CardiniChange = function(self)
		self.cards[52]:SetFacingUp(false)
		self:MoveToPosition(52, 1)
	end,

	StartSpin = function(self)
		self.cards[52]:SetState(GameConstants.CardStates.SpinningOut)
	end,

	CatchCard = function(self)
		if Common:DistanceSquared(self.cards[52].position.x, self.cards[52].position.y, self.rightHand.position.x, self.rightHand.position.y) < 3000 then
			self.cards[52]:SetState(GameConstants.CardStates.InRightHandPinchPalmDown)
			self:BroadcastToListeners("CatchCard")
		end
	end,

	ResetSpinCard = function(self)
		self.cards[26].inRightHand = false
		self.cards[26].spinning = false
		self.cards[26].out = false
		self.cards[26].angle = 0
		self.cards[26].targetAngle = 0
	end,

	OnCardDropped = function(self, card)
		self:BroadcastToListeners("OnCardDropped")
	end,

	-----------------------------------------------------------------------------------------------------------
	-- !SECTION
	-- SECTION Listeners
	-----------------------------------------------------------------------------------------------------------
	AddListener = function(self, functionName, callbackTable, callbackFunction)
		if not self.notificationListeners[functionName] then
			self.notificationListeners[functionName] = {}
		end
		--print("AddListener: functionName=", functionName)
		self.listenerId = self.listenerId + 1
		self.notificationListeners[functionName][self.listenerId] = {
			callbackTable = callbackTable,
			callbackFunction = callbackFunction,
		}
		return self.listenerId
	end,

	RemoveListener = function(self, functionName, listenerId)
		if not self.notificationListeners[functionName] then
			print("RemoveListener: No notification found for function=", functionName)
			return
		end
		if not self.notificationListeners[functionName][listenerId] then
			print("RemoveListener: No notification found for function=", functionName, " with listenerId=", listenerId)
			return
		end
		self.notificationListeners[functionName][listenerId] = nil
	end,

	BroadcastToListeners = function(self, functionName, params)
		if not self.notificationListeners[functionName] then
			return
		end
		--print("BroadcastToListeners: Listener count=", Common:TableCount(self.notificationListeners[functionName]))
		for _, dataTable in pairs(self.notificationListeners[functionName]) do
			dataTable.callbackTable[dataTable.callbackFunction](dataTable.callbackTable, params)
		end
	end,

	-----------------------------------------------------------------------------------------------------------
	-- !SECTION
	-- SECTION Getters/Setters
	-----------------------------------------------------------------------------------------------------------

	GetCard = function(self, cardIndex)
		if cardIndex < 1 or cardIndex > 52 then
			print("GetCard: cardIndex is out of bounds. index=", cardIndex)
			return nil
		end
		return self.cards[cardIndex]
	end,

	GetCards = function(self)
		return self.cards
	end,

	-----------------------------------------------------------------------------------------------------------
	-- !SECTION
	-----------------------------------------------------------------------------------------------------------
}

Deck.__index = Deck
return Deck