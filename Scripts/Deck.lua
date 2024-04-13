local Common = require("Scripts.Common")
local PlayingCard = require ("Scripts.PlayingCard")
local Constants = require ("Scripts.Constants")

local Deck = {
	New = function(self, leftHand, rightHand)
		local instance = setmetatable({}, self)
		instance.cards = {}
		instance.fannedCards = 0
		instance.offsetCardIndex = nil
		instance.leftHand = leftHand
		instance.rightHand = rightHand
		instance.inLeftHand = true

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
			instance.clubs[cardValue] = PlayingCard.New(cardValue, Constants.CardSuits.Clubs, cardSpritesheet, clubQuad, nil, faceDownSprite, leftHand, rightHand)
			instance.cards[cardValue] = instance.clubs[cardValue]

			local diamondQuad = love.graphics.newQuad(x, cardHeight, cardWidth, cardHeight, spritesheetWidth, spritesheetHeight)
			instance.diamonds[cardValue] = PlayingCard.New(cardValue, Constants.CardSuits.Diamonds, cardSpritesheet, diamondQuad, nil, faceDownSprite, leftHand, rightHand)
			instance.cards[cardValue + 13] = instance.diamonds[cardValue]

			local heartQuad = love.graphics.newQuad(x, cardHeight * 2, cardWidth, cardHeight, spritesheetWidth, spritesheetHeight)
			instance.hearts[cardValue] = PlayingCard.New(cardValue, Constants.CardSuits.Hearts, cardSpritesheet, heartQuad, nil, faceDownSprite, leftHand, rightHand)
			instance.cards[cardValue + 26] = instance.hearts[cardValue]

			local spadeQuad = love.graphics.newQuad(x, cardHeight * 3, cardWidth, cardHeight, spritesheetWidth, spritesheetHeight)
			instance.spades[cardValue] = PlayingCard.New(cardValue, Constants.CardSuits.Spades, cardSpritesheet, spadeQuad, nil, faceDownSprite, leftHand, rightHand)
			instance.cards[cardValue + 39] = instance.spades[cardValue]
			
            x = x + cardWidth
        end

		instance.notificationListeners = {}
		return instance
	end,

	Update = function(self, Flux, dt)
		for index, card in ipairs(self.cards) do
			card:Update(Flux, dt)
		end

		if self.fanSpreading then
			self:DuringFanSpread()
		end
		self:SpreadingLines()
	end,

	Draw = function(self)
		for _, card in ipairs(self.cards) do
			card:Draw()
		end

		for _, line in pairs(self.lines) do
            love.graphics.line(line.x1, line.y1, line.x2, line.y2)
        end
    end,

	LateDraw = function(self)
		
		-- local numberOfLines = Common:TableCount(self.lines)
		-- if numberOfLines == 0 then
		-- 	return
		-- end

		-- local targetLine = self.lines[numberOfLines]
		-- if not targetLine then
		-- 	return
		-- end

		-- local card = self.cards[1]
		-- love.graphics.setColor(1, 0, 0, 1)
		-- love.graphics.line(targetLine.x1, targetLine.y1, card.position.x, card.position.y)
		-- love.graphics.setColor(1, 1, 1, 1)
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
	---@param a number index of element to swap
	---@param b number newIndex
	MoveToPosition = function(self, a, b)
		table.insert(self.cards, b, table.remove(self.cards, a))
	end,

	CardiniChange = function(self)
		self.cards[52]:SetFacingUp(false)
		self:MoveToPosition(52, 1)
	end,

	ToggleFan = function(self)
		if self.fannedCards == 0 then
			self:Fan()
		else
			self:Unfan()
		end
	end,

	DuringFanSpread = function(self)
		local numberOfLines = Common:TableCount(self.lines)
		if numberOfLines == 0 then
			return
		end
		local targetLine = self.lines[numberOfLines]
		if not targetLine then
			return
		end
		if love.mouse.getX() < self.leftHand.position.x then
			return
		end
		for _, card in ipairs(self.spreadingCards) do
			local v2 = Common:Normalize({ x = targetLine.x2 - card.position.x, y = targetLine.y2 - card.position.y })
			local v1 = { x = 0, y = -1 }
			local newAngle = Common:AngleBetweenVectors(v1, v2)
			local angleDelta = (newAngle - card.targetAngle)
			card.targetAngle = (card.targetAngle + angleDelta) * 2
		end
	end,

	OnNewLineCreated = function(self, lineIndex)
		if not self.spreadingCards then
			return
		end
		table.remove(self.spreadingCards, 1)
	end,

	FanSpread = function(self)
		self.fanSpreading = true
		for _, card in ipairs(self.cards) do
			card.targetOffset = { x = 0, y = card.halfHeight }
			card.previousOffset = { x = 0, y = card.halfHeight }
		end
		self.spreadingCards = {}
		for index, card in ipairs(self.cards) do
			self.spreadingCards[index] = card
		end
	end,

	UnfanSpread = function(self)
		self.fanSpreading = false
		self:Unfan()
	end,

	SpreadingLines = function(self)
		if not love.mouse.isDown(1) then
			if self.originPoint then
				self.originPoint = nil
			end
			self.lines = {}
			self.lineIndex = 1
		end

		local leftHandPos = self.leftHand.position
		local indexFingerPos = self.rightHand:GetIndexFingerPosition()

		local handsDistance = Common:DistanceSquared(leftHandPos.x, leftHandPos.y, indexFingerPos.x, indexFingerPos.y)
		if handsDistance > 20000 then
			return
		end
		if indexFingerPos.x < self.cards[1].position.x then
			return
		end
		if love.mouse.isDown(1) then
			if not self.lines[self.lineIndex] then
				local x = indexFingerPos.x
				local y = indexFingerPos.y
				if self.lines[self.lineIndex - 1] then
					x = self.lines[self.lineIndex - 1].x2
					y = self.lines[self.lineIndex - 1].y2
				end
				self.lines[self.lineIndex] = { x1 = x, y1 = y, x2 = x, y2 = y }
			end
			self.lines[self.lineIndex].x2 = indexFingerPos.x
			self.lines[self.lineIndex].y2 = indexFingerPos.y
			if Common:DistanceSquared(self.lines[self.lineIndex].x1, self.lines[self.lineIndex].y1, self.lines[self.lineIndex].x2, self.lines[self.lineIndex].y2) > 30 then
				self.lineIndex = self.lineIndex + 1
				self:OnNewLineCreated(self.lineIndex)
			end
		end
	end,

	Fan = function(self)
		local angleIncrement = 8
		local angle = 0
		self.fannedCards = 0
		for index, card in ipairs(self.cards) do
			card.targetOffset = { x = 0, y = card.halfHeight }
			card.previousOffset = { x = 0, y = card.halfHeight }
			card.targetAngle = angle
			if angle < 180 then
				angle = angle + angleIncrement
				self.fannedCards = self.fannedCards + 1
			end
		end
	end,

	Unfan = function(self)
		for index, card in ipairs(self.cards) do
			card.targetOffset = { x = 0, y = 0 }
			card.previousOffset = { x = 0, y = 0 }
			card.targetAngle = 0
		end
		self.fannedCards = 0
	end,

	OffsetCard = function(self, cardIndex)
		if self.fannedCards == 0 then
			return
		end
		if self.offsetCardIndex then
			self:UnoffsetCard(self.offsetCardIndex)
		end
		self.cards[cardIndex].previousOffset = { x = self.cards[cardIndex].offset.x, y = self.cards[cardIndex].offset.y }
		self.cards[cardIndex].targetOffset = { x = 0, y = self.cards[cardIndex].offset.y + self.cards[cardIndex].halfHeight }
		self.offsetCardIndex = cardIndex
	end,
	
	UnoffsetCard = function(self, cardIndex)
		self.cards[cardIndex].targetOffset = { x = self.cards[cardIndex].previousOffset.x, y = self.cards[cardIndex].previousOffset.y }
		self.offsetCardIndex = nil
	end,

	OffsetRandomCard = function(self)
		local randomCardIndex = love.math.random(1, self.fannedCards)
		self:OffsetCard(randomCardIndex)
	end,

	GiveSelectedCard = function(self)
		if self.offsetCardIndex then
			self.cards[self.offsetCardIndex].targetPosition = { x = 600, y = 100 }
			self.cards[self.offsetCardIndex].targetOffset = { x = 0, y = 0 }
			self.cards[self.offsetCardIndex].targetAngle = 0
			self.cards[self.offsetCardIndex].out = true
			self.cards[self.offsetCardIndex].facingUp = true
		end
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

	FlipDeck = function(self)
		local reversed = {}
		for i = 52, 1, -1 do
			self.cards[i]:Flip()
			table.insert(reversed, self.cards[i])
		end
		self.cards = reversed
	end,

	StartSpin = function(self)
		self.cards[26]:SetPosition({x = self.leftHand.position.x, y = self.leftHand.position.y })
		local randomY = love.math.random(0, love.graphics.getHeight())
		self.cards[26].targetPosition = { x = love.graphics.getWidth() + 100, y = randomY }
		self.cards[26].spinning = true
		self.cards[26].out = true
		self.cards[26].inRightHand = false
	end,

	CatchCard = function(self)
		if Common:DistanceSquared(self.cards[26].position.x, self.cards[26].position.y, self.rightHand.position.x, self.rightHand.position.y) < 3000 then
			self.cards[26].spinning = false
			self.cards[26].inRightHand = true
		end
	end,
}

Deck.__index = Deck
return Deck