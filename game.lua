-- External Libraries
local Flux = require("Scripts.libraries.flux")

-- UI
local MainMenu = require ("Scripts.UI.MainMenu")

-- Helpers
local Constants = require ("Scripts.Contants")

-- Game objects
local PlayingCard = require ("Scripts.PlayingCard")
local RightHand = require("Scripts.RightHand")
local LeftHand = require("Scripts.LeftHand")
local Deck = require("Scripts.Deck")

-- Techniques
--local CardSpread = require("Scripts.Techniques.CardSpread")

-- Tricks
local ErdnaseChange = require("Scripts.Tricks.ErdnaseChange")

local game = {

    Load = function(self)
        self.gameState = Constants.GameStates.Game
        self.mainMenu = MainMenu
        self.mainMenu:Load(self)
        print("Load: self.gameState=", self.gameState)

        self:LoadCardSprites()
		self.leftHand = LeftHand.New()
        self.rightHand = RightHand.New()
		self.erdnaseChange = ErdnaseChange:New(self.leftHand, self.rightHand, self.deck)

		self.erdnaseChange:Start()
		love.mouse.setVisible(false)
    end,

    LoadCardSprites = function(self)
		--------------------------------------------------------------------------------------------------------------
		-- Create all card objects
		-- One card object for each suit/value (1-13, 1=Ace 11=Jack, 12=Queen, 13=King)
		--------------------------------------------------------------------------------------------------------------
		self.deck = Deck:New()
        self.cards = {}
        self.cards.clubs = {}
        self.cards.hearts = {}
        self.cards.diamonds = {}
        self.cards.spades = {}

        local clubsSpritesheet = love.graphics.newImage("Images/Cards/TopDown/Clubs.png")
        local diamondsSpritesheet = love.graphics.newImage("Images/Cards/TopDown/Diamonds.png")
        local heartsSpritesheet = love.graphics.newImage("Images/Cards/TopDown/Hearts.png")
        local spadesSpritesheet = love.graphics.newImage("Images/Cards/TopDown/Spades.png")
        
        local cardWidth = 88
        local cardHeight = 124
        local spritesheetWidth = clubsSpritesheet:getWidth()
        local spritesheetHeight = clubsSpritesheet:getHeight()

		local faceDownSpritesheet = love.graphics.newImage("Images/Cards/TopDown/Back.png")
        local faceDownQuad = love.graphics.newQuad(cardWidth, 0, cardWidth, cardHeight, faceDownSpritesheet:getWidth(), faceDownSpritesheet:getHeight())

        local cardQuads = {}
		local x = 0
        local y = 0
        for cardValue = 1, 13 do
            cardQuads[cardValue] = love.graphics.newQuad(x, y, cardWidth, cardHeight, spritesheetWidth, spritesheetHeight)
			self.cards.spades[cardValue] = PlayingCard.New(cardValue, Constants.CardSuits.Spades, spadesSpritesheet, cardQuads[cardValue], nil, faceDownSpritesheet, faceDownQuad)
			self.deck.cards[cardValue] = self.cards.spades[cardValue]
			self.cards.hearts[cardValue] = PlayingCard.New(cardValue, Constants.CardSuits.Hearts, heartsSpritesheet, cardQuads[cardValue], nil, faceDownSpritesheet, faceDownQuad)
			self.deck.cards[cardValue + 13] = self.cards.hearts[cardValue]
            self.cards.clubs[cardValue] = PlayingCard.New(cardValue, Constants.CardSuits.Clubs, clubsSpritesheet, cardQuads[cardValue], nil, faceDownSpritesheet, faceDownQuad)
			self.deck.cards[cardValue + 26] = self.cards.clubs[cardValue]
            self.cards.diamonds[cardValue] = PlayingCard.New(cardValue, Constants.CardSuits.Diamonds, diamondsSpritesheet, cardQuads[cardValue], nil, faceDownSpritesheet, faceDownQuad)
            self.deck.cards[cardValue + 39] = self.cards.diamonds[cardValue]
            x = x + cardWidth
            if x >= spritesheetWidth then
                x = 0
                y = y + cardHeight
            end
        end

		--------------------------------------------------------------------------------------------------------------
		--------------------------------------------------------------------------------------------------------------
    end,

    Update = function(self, dt)
        self:HandleInput()
        if self.gameState == Constants.GameStates.MainMenu then
            self.mainMenu:Update(dt)
            return
        end
        self.erdnaseChange:Update(Flux, dt)
		Flux.update(dt)
    end,

    Draw = function(self)
        if self.gameState == Constants.GameStates.MainMenu then
            self.mainMenu:Draw()
        else
			self.erdnaseChange:Draw()
        end
    end,

    OnGameStateChanged = function(self, newState)
        self.gameState = newState
    end,

    HandleInput = function(self)
        if love.keyboard.isDown("escape") then
            love.window.close()
        end
    end,
}
return game