local MainMenu = require ("Scripts.UI.MainMenu")
local Constants = require ("Scripts.Contants")
local PlayingCard = require ("Scripts.PlayingCard")
local Hand = require("Scripts.Hand")
local Flux = require("Scripts.libraries.flux")
local Deck = require("Scripts.Deck")
local CardSpread = require("Scripts.Techniques.CardSpread")

local game = {

    Load = function(self)
        self.gameState = Constants.GameStates.Game
        self.mainMenu = MainMenu
        self.mainMenu:Load(self)
        print("Load: self.gameState=", self.gameState)

        self:LoadCardSprites()
        self.hand = Hand.New() 
    end,

    LoadCardSprites = function(self)
        self.cards = {}
        self.cards.clubs = {}
        self.cards.hearts = {}
        self.cards.diamonds = {}
        self.cards.spades = {}

        self.clubsSpritesheet = love.graphics.newImage("Images/Cards/TopDown/Clubs.png")
        self.diamondsSpritesheet = love.graphics.newImage("Images/Cards/TopDown/Diamonds.png")
        self.heartsSpritesheet = love.graphics.newImage("Images/Cards/TopDown/Hearts.png")
        self.spadesSpritesheet = love.graphics.newImage("Images/Cards/TopDown/Spades.png")
        self.deckSpritesheet = love.graphics.newImage("Images/Cards/TopDown/DeckVertical.png")

        local x = 0
        local y = 0
        local cardWidth = 88
        local cardHeight = 124
        local spritesheetWidth = self.clubsSpritesheet:getWidth()
        local spritesheetHeight = self.clubsSpritesheet:getHeight()

        local cardQuads = {}
        for cardValue = 1, 13 do
            cardQuads[cardValue] = love.graphics.newQuad(x, y, cardWidth, cardHeight, spritesheetWidth, spritesheetHeight)
            self.cards.clubs[cardValue] = PlayingCard.New(self.clubsSpritesheet, cardQuads[cardValue])
            self.cards.hearts[cardValue] = PlayingCard.New(self.heartsSpritesheet, cardQuads[cardValue])
            self.cards.diamonds[cardValue] = PlayingCard.New(self.diamondsSpritesheet, cardQuads[cardValue])
            self.cards.spades[cardValue] = PlayingCard.New(self.spadesSpritesheet, cardQuads[cardValue])
            x = x + cardWidth
            if x >= spritesheetWidth then
                x = 0
                y = y + cardHeight
            end
        end

        self.faceDownPlayingCards = {}
        local faceDownSpritesheet = love.graphics.newImage("Images/Cards/TopDown/Back.png")
        local faceDownQuad = love.graphics.newQuad(88, 0, cardWidth, cardHeight, faceDownSpritesheet:getWidth(), faceDownSpritesheet:getHeight())
        for cardValue = 1, 52 do
            self.faceDownPlayingCards[cardValue] = PlayingCard.New(faceDownSpritesheet, faceDownQuad)
        end

        self.deck = Deck.New()
        self.changed = false
    end,

    Update = function(self, dt)
        self:HandleInput()
        if self.gameState == Constants.GameStates.MainMenu then
            self.mainMenu:Update(dt)
            return
        end
        self.hand:FollowMouse(Flux)
        local positionX = self.hand.position.x + self.hand.halfWidth / 2
        local positionY = self.hand.position.y + self.hand.halfHeight / 2
        local distanceSquared = self:DistanceSquared(positionX, positionY, self.deck.position.x, self.deck.position.y)
        if self.hand and not self.changed and distanceSquared < 50 then
            self.changed = true
        end

        self.deck:HandleMovement(Flux, dt)
        Flux.update(dt)
        for key, faceDownPlayingCard in pairs(self.faceDownPlayingCards) do
            faceDownPlayingCard:SetPosition({x = self.deck.position.x, y = self.deck.position.y })
        end
        -- self.cards.clubs[4]:SetPosition({x = self.deck.position.x, y = self.deck.position.y })
        -- self.cards.hearts[10]:SetPosition({x = self.deck.position.x, y = self.deck.position.y })
    end,

    Draw = function(self)
        if self.gameState == Constants.GameStates.MainMenu then
            self.mainMenu:Draw()
        else
            self.deck:Draw()
            for key, faceDownPlayingCard in pairs(self.faceDownPlayingCards) do
                faceDownPlayingCard:Draw()
            end
            self.hand:Draw()
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

    DistanceSquared = function(self, x1, y1, x2, y2)
        return (x2-x1)^2 + (y2-y1)^2
    end,

    -- GenerateRandomScreenPosition = function(self)
    --     local cardWidth = 88
    --     local cardHeight = 124
    --     local windowX, windowY = love.graphics.getDimensions()
    --     local randX = math.random(windowX - cardWidth)
    --     local randY = math.random(windowY - cardHeight)
    --     return { x = randX, y = randY }
    -- end,

}
return game