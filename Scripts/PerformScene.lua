-- Game objects
local RightHand = require("Scripts.RightHand")
local LeftHand = require("Scripts.LeftHand")
local Deck = require("Scripts.Deck")
local Constants = require ("Scripts.Constants")
local CardShootCatch = require ("Scripts.Tricks.CardShootCatch")

local PerformScene =
{
    Load = function(self, gameInstance, keyboardUI, input, hud)
		self.gameInstance = gameInstance
		self.background = love.graphics.newImage("Images/Background/mat.png")
        self.keyboardUI = keyboardUI
		self.leftHand = LeftHand.New()
        self.rightHand = RightHand.New()
		self.deck = Deck:New(self.leftHand, self.rightHand)
		self.input = input
		self.hud = hud

		self.routine = {
			[1] = CardShootCatch:New(self.deck, self.leftHand, self.rightHand, input)
		}
		self.routineIndex = 1
		
    end,

	OnStart = function(self)
		self.input:AddKeyListener("tab", self, "ExitPerform")
		self.routine[self.routineIndex]:OnStart()
	end,

	OnStop = function(self)
	end,

    Update = function(self, Flux, dt)
		self.deck:Update(Flux, dt)
		self.rightHand:FollowMouse(Flux)
		self.leftHand:HandleMovement(Flux, dt)
    end,

    Draw = function(self)
		love.graphics.draw(self.background, 0, 0, 0, 4, 4)
		self.leftHand:Draw()
		self.deck:Draw()
		self.rightHand:Draw()
    end,

	LateDraw = function(self)
		self.deck:LateDraw()
	end,

	ExitPerform = function(self)
		self.gameInstance:OnGameStateChanged(Constants.GameStates.Streets)
	end,

	StartNextRoutineStep = function(self)
		self.routine[self.routineIndex]:OnStop()
		self.routineIndex = self.routineIndex + 1
		self.routine[self.routineIndex]:OnStart()
	end,

}
return PerformScene