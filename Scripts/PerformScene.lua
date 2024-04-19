-- Game objects
local RightHand = require("Scripts.RightHand")
local LeftHand = require("Scripts.LeftHand")
local Deck = require("Scripts.Deck")
local Constants = require ("Scripts.Constants")
local CardShootCatch = require ("Scripts.Tricks.CardShootCatch")
local Fan = require("Scripts.Techniques.Fan")

local PerformScene =
{
    Load = function(self, gameInstance, keyboardUI, input, hud, timer, flux)
		self.gameInstance = gameInstance
		self.background = love.graphics.newImage("Images/Background/mat.png")
        self.keyboardUI = keyboardUI
		self.leftHand = LeftHand.New()
        self.rightHand = RightHand.New()
		self.deck = Deck:New(self.leftHand, self.rightHand, flux)
		self.input = input
		self.hud = hud
		self.routine = {
			Fan:New(self.deck, input, timer),
			CardShootCatch:New(self.deck, input),
		}
		
		local routineHudText = {}
		for index, techniqueTable in ipairs(self.routine) do
			routineHudText[index] = techniqueTable:GetName()
		end
		self.hud:SetRoutineText(routineHudText)
		
		self:EquipRoutineIndex(1)
    end,

	OnStart = function(self)
		self.input:AddKeyListener("tab", self, "ExitPerform")
		self.input:AddKeyListener("1", self, "EquipOne")
		self.input:AddKeyListener("2", self, "EquipTwo")
		self.input:AddKeyListener("3", self, "EquipThree")
		self.input:AddKeyListener("4", self, "EquipFour")
		self.input:AddKeyListener("5", self, "EquipFive")
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

	EquipRoutineIndex = function(self, index)
		if self.routineIndex == index then
			return
		end
		if not self.routine[index] then
			return
		end
		if self.routineIndex and self.routine[self.routineIndex] then
			self.routine[self.routineIndex]:OnStop()
		end
		
		self.routineIndex = index
		self.routine[self.routineIndex]:OnStart()
		self.hud:SetRoutineIndex(index)
	end,

	EquipOne = function(self)
		self:EquipRoutineIndex(1)
	end,
	
	EquipTwo = function(self)
		self:EquipRoutineIndex(2)
	end,

	EquipThree = function(self)
		self:EquipRoutineIndex(3)
	end,

	EquipFour = function(self)
		self:EquipRoutineIndex(4)
	end,

	EquipFive = function(self)
		self:EquipRoutineIndex(5)
	end,
}
return PerformScene