-- Game objects
local RightHand = require("Scripts.RightHand")
local LeftHand = require("Scripts.LeftHand")
local Deck = require("Scripts.Deck")
local CardShootCatch = require ("Scripts.Tricks.CardShootCatch")
local DoubleLift = require("Scripts.Techniques.DoubleLift")
local CardiniChange = require("Scripts.Tricks.CardiniChange")
local TableSpread   = require("Scripts.Techniques.TableSpread")
local Fan = require("Scripts.Techniques.Fan")
local FalseCut = require("Scripts.Techniques.FalseCut")
local Audience = require("Scripts.Audience.Audience")
local Mat = require("Scripts.Mat")

local PerformScene =
{
    Load = function(self)
		-- Create new objects
		self.audience = Audience:New()
		self.leftHand = LeftHand:New()
        self.rightHand = RightHand:New()
		self.deck = Deck:New(self.leftHand, self.rightHand)
		

		Mat:Load()
		-- Variables
		self.routine = {
			--TableSpread:New(self.deck, self.leftHand, self.rightHand),
			Fan:New(self.deck, self.leftHand, self.rightHand),
			FalseCut:New(self.deck, self.leftHand, self.rightHand),
			--DoubleLift:New(self.deck, self.leftHand, self.rightHand),
			-- CardiniChange:New(self.deck, self.leftHand, self.rightHand),
			CardShootCatch:New(self.deck, self.leftHand, self.rightHand),
		}
		
		local routineHudText = {}
		for index, techniqueTable in ipairs(self.routine) do
			routineHudText[index] = techniqueTable:GetName()
		end
		HUD:SetRoutineText(routineHudText)


		self:EquipRoutineIndex(1)


		local img = love.graphics.newImage("Images/Cards/heart_01.png")

		self.psystem = love.graphics.newParticleSystem(img, 1000)
		self.psystem:setParticleLifetime(2, 5) -- Particles live at least 2s and at most 5s.
		self.psystem:setEmissionRate(100)
		self.psystem:setLinearAcceleration(0, -20, 0, -20) -- Random movement in all directions.
		self.psystem:setColors(1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0) -- Fade to transparency.
		self.psystem:setSizes(1, 0)
		--self.psystem:setSpeed(20, 20)
		self.psystemPosition = { x = 0, y = 0 }
    end,

	OnStart = function(self)
		Input:AddKeyListener("1", self, "EquipOne")
		Input:AddKeyListener("2", self, "EquipTwo")
		Input:AddKeyListener("3", self, "EquipThree")
		Input:AddKeyListener("4", self, "EquipFour")
		Input:AddKeyListener("5", self, "EquipFive")
		Input:AddKeyListener("space", self, "MoveParticle")
		love.mouse.setVisible(true)
	end,

	OnStop = function(self)
	end,

    Update = function(self, dt)
		self.deck:Update(dt)
		self.rightHand:Update(dt)
		self.leftHand:Update(dt)
		if self.routine[self.routineIndex].Update then
			self.routine[self.routineIndex]:Update(dt)
		end
		self.psystem:update(dt)
		self.psystem:moveTo(self.psystemPosition.x, self.psystemPosition.y)
    end,

	FixedUpdate = function(self, dt)
		self.deck:FixedUpdate(dt)
		self.audience:FixedUpdate(dt)
	end,

    Draw = function(self)
		love.graphics.setBackgroundColor(0.128, 0.128, 0.136, 1)
		Mat:Draw()

		self.audience:Draw()
		self.leftHand:Draw()
		self.rightHand:Draw()
		self.deck:Draw()
		if self.routine[self.routineIndex].Draw then
			self.routine[self.routineIndex]:Draw()
		end

		love.graphics.draw(self.psystem)
    end,

	LateDraw = function(self)
		self.leftHand:LateDraw()
		self.rightHand:LateDraw()
		HUD:Draw()
	end,

	MoveParticle = function(self)
		Flux.to(self.psystemPosition, 0.5, { x = love.mouse.getX(), y = love.mouse.getY() } ):ease("cubicinout")
	end,

	OnTechniqueEvaluated = function(self, score)
		self.audience:SetAudienceAwe(score)
		print("OnTechniqueEvaluated: score=", score)
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
		self.routine[self.routineIndex]:Technique_HookFunction("Technique_OnTechniqueEvaluated", function(params)
			self:OnTechniqueEvaluated(params.score)
		end)
		HUD:SetRoutineIndex(index)
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