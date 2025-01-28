local RightHand = require("Scripts.Player.RightHand")
local LeftHand = require("Scripts.Player.LeftHand")
local Deck = require("Scripts.Deck")
local CreditCard = require("Scripts.Items.Pickup.CreditCard")
local Inventory = require("Scripts.Player.Inventory")
local Projectile = require("Scripts.Player.Projectile")
local EventIds = require("Scripts.System.EventIds")

local Techniques = 
{
    CardShootCatch = require ("Scripts.Tricks.CardShootCatch"),
    DoubleLift = require("Scripts.Techniques.DoubleLift"),
    CardiniChange = require("Scripts.Tricks.CardiniChange"),
    TableSpread   = require("Scripts.Techniques.TableSpread"),
    Fan = require("Scripts.Techniques.Fan"),
    FalseCut = require("Scripts.Techniques.FalseCut"),
}

local Player = 
{
    -- ===========================================================================================================
    -- #region [CORE]
    -- ===========================================================================================================
    Load = function(self)
        self.leftHand = LeftHand:New()
        self.rightHand = RightHand:New()
		self.deck = Deck:New(self.leftHand, self.rightHand)
        self.creditCard = CreditCard:New(self.leftHand, self.rightHand)

		Projectile:Load()
        Inventory:Load()

        self.routine = {}
		self.activeProjectiles = {}
		self.techniqueCards = {}

        self.equippedRoutineIndex = 1
		Log.High("Load: Player loaded")
    end,

    OnStart = function(self)
	end,

	OnStop = function(self)
	end,

    Update = function(self, dt)
        self.deck:Update(dt)
        self.leftHand:Update(dt)
        self.rightHand:Update(dt)
        self.creditCard:Update(dt)
        Inventory:Update(dt)

        if self.routineIndex and self.routine[self.routineIndex] then
            if self.routine[self.routineIndex].Update then
                self.routine[self.routineIndex]:Update(dt)
            end
        end

    end,

    FixedUpdate = function(self, dt)
        self.deck:FixedUpdate(dt)
        self.leftHand:FixedUpdate(dt)
        self.rightHand:FixedUpdate(dt)

        if self.routineIndex and self.routine[self.routineIndex] then
            if self.routine[self.routineIndex].FixedUpdate then
                self.routine[self.routineIndex]:FixedUpdate(dt)
            end
        end

		for _, projectile in ipairs(self.activeProjectiles) do
			projectile:FixedUpdate(dt)
			local projectileSprite = projectile:GetSprite()
			if self.projectileSpriteBatch then
				self.projectileSpriteBatch.spriteBatch:set(
					projectile.spriteBatchId,
					projectileSprite.position.x,
					projectileSprite.position.y,
					math.rad(projectileSprite.angle),
					GameSettings.WindowResolutionScale * projectileSprite.scaleModifier * (1 + (projectileSprite.position.z / 100)),
					GameSettings.WindowResolutionScale * projectileSprite.scaleModifier * (1 + (projectileSprite.position.z / 100)),
					projectileSprite.width * projectileSprite.originOffsetRatio.x,
					projectileSprite.height * projectileSprite.originOffsetRatio.y
				)
			end
		end
	end,

    -- ===========================================================================================================
    -- #region [EXTERNAL]
    -- ===========================================================================================================
    OnStartPerform = function(self, spectators)
		self.spectators = spectators
        self.leftHand:OnStartPerform()
        self.rightHand:OnStartPerform()
        self.deck:OnStart()
        self:EquipDeckInLeftHand()

        self:SetRoutineIndex(1, "Fan")
		self:SetRoutineIndex(2, "Fan")
		self:SetRoutineIndex(3, "Fan")
        self:EquipRoutineIndex(self.equippedRoutineIndex)

		self.scoreNotificationId = EventSystem:ConnectToEvent(EventIds.TechniqueEvaluated, self, "OnTechniqueEvaluated")
		self.projectileNotificationId = EventSystem:ConnectToEvent(EventIds.ProjectileHit, self, "OnProjectileHit")
		self.techniqueFinishedNotificationId = EventSystem:ConnectToEvent(EventIds.PlayerTechniqueFinished, self, "OnTechniqueFinished")

		for index, technique in pairs(self.routine) do
			technique:Technique_GetTechniqueCard():OnStart()
		end
		self:UpdateTechniqueCardPositions()
    end,

    OnStopPerform = function(self)
        self.leftHand:OnStopPerform()
        self.rightHand:OnStopPerform()
    end,

    OnStartBuild = function(self)
        self.deck:SetActive(false)
        self.deck:SetVisible(false)

        self.leftHand:OnStartBuild()
        self.rightHand:OnStartBuild()
    end,

    OnStopBuild = function(self)
        self.leftHand:OnStopBuild()
        self.rightHand:OnStopBuild()
    end,

    OnStartShop = function(self)
        self.leftHand:OnStartShop()
        self.rightHand:OnStartShop()
        self.creditCard:OnStart()
    end,

    OnStopShop = function(self)
        self.leftHand:OnStopShop()
        self.rightHand:OnStopShop()
    end,

    -- ===========================================================================================================
    -- #region [INTERNAL]
    -- ===========================================================================================================

    EquipDeckInLeftHand = function(self)
        self.leftHand:SetState(GameConstants.HandStates.MechanicsGrip)
        self.deck:SetDeckInLeftHand()
    end,

    EquipRoutineIndex = function(self, index)
		if self.routineIndex == index then
            Log.Med("EquipRoutineIndex: routineIndex is already set to: ", index)
			return
		end

		if self.routineIndex and self.routine[self.routineIndex] then
			self.routine[self.routineIndex]:OnStop()
			Log.Med("EquipRoutineIndex: Completed=", self.routineIndex)
		end

        if self.routine[index] == nil then
            Log.Med("EquipRoutineIndex: No technique initialised at routineIndex=", index)
			return
		end

        Log.Med("EquipRoutineIndex: Equipping index=", index)
		self.routineIndex = index
		self.routine[self.routineIndex]:OnStart()
	end,

	UpdateTechniqueCardPositions = function(self)
		for index, technique in pairs(self.routine) do
			local targetPosition = ((index - self.routineIndex) * 150) + (love.graphics.getWidth() / 2)
			local techniqueCard = technique:Technique_GetTechniqueCard()
			local techniqueCardSprite = techniqueCard:GetSprite()
			if index - self.routineIndex == 0 then
				techniqueCardSprite:SetColorOverride({1.0, 1.0, 1.0, 1.0})
				techniqueCardSprite:SetScaleModifier(1.2)
			else
				techniqueCardSprite:SetColorOverride({0.5, 0.5, 0.5, 1.0})
				techniqueCardSprite:SetScaleModifier(1)
			end
			techniqueCard:FluxPositionTo({x = targetPosition, y = techniqueCard:GetPosition().y }, 0.5)
		end
	end,

	OnTechniqueEvaluated = function(self, techniqueName, score)
		local spectatorCount = table.count(self.spectators)
		local projectileImage = Projectile:GetImage()
		self.projectileSpriteBatch = Sprite:NewSpriteBatch(projectileImage, spectatorCount, DrawLayers.Projectiles)

		for _, spectator in pairs(self.spectators) do
			self:CreateProjectile({ x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2, z = 0 }, spectator, score)
		end

		DrawSystem:AddDrawable(self.projectileSpriteBatch)
		Log.Med("OnTechniqueEvaluated: Create spectator count=", spectatorCount)
	end,

	OnTechniqueFinished = function(self)
		Log.Med("OnTechniqueFinished: self.routineIndex=", self.routineIndex)
		self:EquipRoutineIndex(self.routineIndex + 1)
		self:UpdateTechniqueCardPositions()
	end,

	CreateProjectile = function(self, position, target, score)
		local projectile = Projectile:New(
			position,
			target,
			score
		)
		table.insert(self.activeProjectiles, projectile)

		local projectileSprite = projectile:GetSprite()
		projectile.spriteBatchId = self.projectileSpriteBatch.spriteBatch:add(
			projectileSprite.position.x,
			projectileSprite.position.y,
			math.rad(projectileSprite.angle),
			GameSettings.WindowResolutionScale * projectileSprite.scaleModifier * (1 + (projectileSprite.position.z / 100)),
			GameSettings.WindowResolutionScale * projectileSprite.scaleModifier * (1 + (projectileSprite.position.z / 100)),
			projectileSprite.width * projectileSprite.originOffsetRatio.x,
			projectileSprite.height * projectileSprite.originOffsetRatio.y
		)
	end,

	DestroyProjectile = function(self, projectile)
		projectile:OnStop()
		local projectileSprite = projectile:GetSprite()
		self.projectileSpriteBatch.spriteBatch:set(
			projectile.spriteBatchId,
			projectileSprite.position.x,
			projectileSprite.position.y,
			math.rad(projectileSprite.angle),
			GameSettings.WindowResolutionScale * projectileSprite.scaleModifier * (1 + (projectileSprite.position.z / 100)),
			GameSettings.WindowResolutionScale * projectileSprite.scaleModifier * (1 + (projectileSprite.position.z / 100)),
			projectileSprite.width * projectileSprite.originOffsetRatio.x,
			projectileSprite.height * projectileSprite.originOffsetRatio.y
		)

		table.removeByValue(self.activeProjectiles, projectile)
		if table.isEmpty(self.activeProjectiles) then
			self.projectileSpriteBatch.spriteBatch:clear()
			DrawSystem:RemoveDrawable(self.projectileSpriteBatch)
			self.projectileSpriteBatch = nil
		end
	end,

	OnProjectileHit = function(self, projectile, target, score)
		self:DestroyProjectile(projectile)
		target:AddScore(score)
	end,

    -- ===========================================================================================================
    -- #region [PUBLICHELPERS]
    -- ===========================================================================================================
    GetLeftHand = function(self)
        return self.leftHand
    end,

    GetRightHand = function(self)
        return self.rightHand
    end,

    GetDeck = function(self)
        return self.deck
    end,

    SetRoutineIndex = function(self, index, typeId)
        if typeId then
			local techniqueInstance
			if Techniques[typeId] then
				techniqueInstance = Techniques[typeId]:New(self.deck, self.leftHand, self.rightHand)
				self.routine[index] = techniqueInstance
			else
				Log.Error("SetRoutineIndex: No technique found with typeId=", typeId)
			end
        else
            self.routine[index] = nil
        end
    end,

    SetRoutine = function(self, routine)
        self.routine = routine
    end,

    GetRoutine = function(self)
        return self.routine
    end,

    GetCreditCard = function(self)
        return self.creditCard
    end,

    GetInventory = function(self)
        return Inventory
    end,

    -- ===========================================================================================================
    -- #endregion
}
return Player