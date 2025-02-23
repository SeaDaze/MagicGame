local RightHand = require("Scripts.Player.RightHand")
local LeftHand = require("Scripts.Player.LeftHand")
local Deck = require("Scripts.Deck")
local CreditCard = require("Scripts.Items.Pickup.CreditCard")
local Inventory = require("Scripts.Player.Inventory")
local Projectile = require("Scripts.Player.Projectile")
local EventIds = require("Scripts.System.EventIds")
local Techniques = require("Scripts.Techniques.Techniques")
local TechniqueCard = require("Scripts.Items.Pickup.Cards.TechniqueCard")

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

		for typeId, technique in pairs(Techniques) do
			if technique.Load then
				technique:Load(self.deck, self.leftHand, self.rightHand)
			end
		end

		self.routineTechniqueCards = {}
        self.routineTypeIds = {}
		self.currentTechnique = nil
		self.activeProjectiles = {}
        self.equippedRoutineIndex = 1
		self.stats = 
		{
			level = 1,
		}
    end,

    OnStart = function(self)
		self.quotaReachedNotificationId = EventSystem:ConnectToEvent(EventIds.OnQuotaReached, self, "OnQuotaReached")
	end,

	OnStop = function(self)
		EventSystem:DisconnectFromEvent(self.quotaReachedNotificationId)
	end,

    Update = function(self, dt)
        self.deck:Update(dt)
        self.leftHand:Update(dt)
        self.rightHand:Update(dt)
        self.creditCard:Update(dt)
        Inventory:Update(dt)

        if self.currentTechnique then
            if self.currentTechnique.Update then
                self.currentTechnique:Update(dt)
            end
        end

    end,

    FixedUpdate = function(self, dt)
        self.deck:FixedUpdate(dt)
        self.leftHand:FixedUpdate(dt)
        self.rightHand:FixedUpdate(dt)

        if self.currentTechnique then
            if self.currentTechnique.FixedUpdate then
                self.currentTechnique:FixedUpdate(dt)
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

		for index, techniqueCard in pairs(self.routineTechniqueCards) do
			techniqueCard:OnStart()
		end
		self:UpdateTechniqueCardPositions()
    end,

    OnStopPerform = function(self)
		for index, techniqueCard in pairs(self.routineTechniqueCards) do
			techniqueCard:OnStop()
		end
		self.routineTechniqueCards = {}
        self.leftHand:OnStopPerform()
        self.rightHand:OnStopPerform()
		self.deck:OnStop()
		self:EquipRoutineIndex(-1)
		self.routineIndex = -1

		EventSystem:DisconnectFromEvent(self.scoreNotificationId)
		EventSystem:DisconnectFromEvent(self.projectileNotificationId)
		EventSystem:DisconnectFromEvent(self.techniqueFinishedNotificationId)
    end,

    OnStartBuild = function(self)
        self.deck:SetActive(false)

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

		if self.currentTechnique then
			self.currentTechnique:OnStop()
			Log.Med("EquipRoutineIndex: Completed=", self.routineIndex)
		end

        if self.routineTypeIds[index] == nil then
            Log.Med("EquipRoutineIndex: No technique initialised at routineIndex=", index)
			return
		end

        Log.Med("EquipRoutineIndex: Equipping index=", index)
		self.routineIndex = index
		local typeId = self.routineTypeIds[self.routineIndex]
		self.currentTechnique = Techniques[typeId]
		self.currentTechnique:OnStart()
	end,

	UpdateTechniqueCardPositions = function(self)
		for index, techniqueCard in pairs(self.routineTechniqueCards) do
			local targetPosition = ((index - self.routineIndex) * 150) + (love.graphics.getWidth() / 2)
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
		Log.Med("CreateProjectile: active projectile count=", table.count(self.activeProjectiles))
	end,

	DestroyProjectile = function(self, projectile)
		Log.Med("DestroyProjectile: 1")
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
			Log.Med("DestroyProjectile: 2")
		end
	end,

	OnProjectileHit = function(self, projectile, target, score)
		self:DestroyProjectile(projectile)
		target:AddScore(score)
	end,

	OnQuotaReached = function(self)
		self.stats.level = self.stats.level + 1
		Log.Med("OnQuotaReached: level increased to=", self.stats.level)
	end,

	EvaluateQuota = function(self)
		local quota = self.stats.level * self.stats.level * 300
		Log.Med("EvaluateQuota: quota=", quota)
		return quota
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
			if Techniques[typeId] then
				self.routineTypeIds[index] = typeId
				self.routineTechniqueCards[index] = TechniqueCard:New(typeId, self.leftHand, self.rightHand)
			else
				Log.Error("SetRoutineIndex: No technique found with typeId=", typeId)
			end
        else
            self.routineTypeIds[index] = nil
        end
    end,

    GetCreditCard = function(self)
        return self.creditCard
    end,

    GetInventory = function(self)
        return Inventory
    end,

	GetLevel = function(self)
		return self.stats.level
	end,
    -- ===========================================================================================================
    -- #endregion
}
return Player