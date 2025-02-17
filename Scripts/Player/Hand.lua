local EventIds = require("Scripts.System.EventIds")

local Hand = 
{
    -- ===========================================================================================================
    -- #region [CORE]
    -- ===========================================================================================================
    -- ===========================================================================================================
    -- #region [EXTERNAL]
    -- ===========================================================================================================
    OnStartBuild = function(self)
        self:ConnectPickupFunctions()
	end,

	OnStopBuild = function(self)
		self:DisconnectPickupFunctions()
	end,

    OnStartPerform = function(self)
        --self:ConnectPickupFunctions()
        DrawSystem:AddDrawable(self.sprite)
        if self.lateSprite then
            DrawSystem:AddDrawable(self.lateSprite)
        end
	end,

	OnStopPerform = function(self)
		--self:DisconnectPickupFunctions()
        DrawSystem:RemoveDrawable(self.sprite)
        if self.lateSprite then
            DrawSystem:RemoveDrawable(self.lateSprite)
        end
	end,

    OnStartShop = function(self)
        self:ConnectPickupFunctions()
        DrawSystem:AddDrawable(self.sprite)
	end,

	OnStopShop = function(self)
		self:DisconnectPickupFunctions()
        DrawSystem:RemoveDrawable(self.sprite)
	end,

	OnInputAction = function(self, action, pressed)
		if pressed then
			if not table.isEmpty(self.nearbyPickups) then
				self:SetState(GameConstants.HandStates.PalmDownGrabClose)
				local nearestPickup = self:EvaluateNearestPickup()
				if nearestPickup then
					nearestPickup:SetPickedUp(self)
				end
			end
		else
			if table.isEmpty(self.nearbyPickups) then
				self:SetState(GameConstants.HandStates.PalmDownRelaxed)
			else
				self:SetState(GameConstants.HandStates.PalmDownGrabOpen)
				local pickup = self:GetPickup()
				if pickup then
					pickup:SetDropped(self)
				end
			end
		end
	end,

    -- ===========================================================================================================
    -- #region [INTERNAL]
    -- ===========================================================================================================

    EvaluateNearestPickup = function(self)
        local nearbyPickupCount = table.count(self.nearbyPickups)
        if nearbyPickupCount == 0 then
            return nil
        elseif nearbyPickupCount == 1 then
            return self.nearbyPickups[1]
        else
            local smallestDistance = 999999999
            local closestPickup = nil
            for _, pickup in pairs(self.nearbyPickups) do
                local distanceToPickup = Common:DistanceSquared(self.position.x, self.position.y, pickup:GetPosition().x, pickup:GetPosition().y)
                if distanceToPickup < smallestDistance then
                    smallestDistance = distanceToPickup
                    closestPickup = pickup
                end
            end
            return closestPickup
        end
    end,

    ConnectPickupFunctions = function(self)
		self:SetState(GameConstants.HandStates.PalmDownRelaxed)

		self.actionNotificationId = EventSystem:ConnectToEvent(self.actionListenTarget, self, "OnInputAction")
    end,

    DisconnectPickupFunctions = function(self)
		EventSystem:DisconnectFromEvent(self.actionNotificationId)
		self.actionNotificationId = nil
    end,

    -- ===========================================================================================================
    -- #region [PUBLICHELPERS]
    -- ===========================================================================================================
    GetState = function(self)
        return self.state
    end,

    SetState = function(self, newState)
        self.sprite:SetDrawable(self.drawables[newState])
        if self.lateDrawables then
            if self.lateDrawables[newState] then
                self.lateSprite:SetDrawable(self.drawables[newState])
                self.lateSprite:SetVisible(true)
            else
                self.lateSprite:SetVisible(false)
            end
        end
		self.state = newState
	end,

	SetPosition = function(self, newPosition)
        self.sprite.position = newPosition
    end,

	GetPickup = function(self)
		return self.pickup
	end,

	SetPickup = function(self, pickup)
		self.pickup = pickup
	end,

    GetPosition = function(self)
		return self.sprite.position
	end,
	
	Disable = function(self)
		self.active = false
		self.activeTween:stop()
	end,

	Enable = function(self)
		self.active = true
	end,

	AddNearbyPickup = function(self, pickup)
        print("AddNearbyPickup")
		if table.isEmpty(self.nearbyPickups) then
			self:SetState(GameConstants.HandStates.PalmDownGrabOpen)
		end
		table.insert(self.nearbyPickups, pickup)
	end,

	RemoveNearbyPickup = function(self, pickup)
        print("RemoveNearbyPickup")
		table.removeByValue(self.nearbyPickups, pickup)
		if table.isEmpty(self.nearbyPickups) then
			self:SetState(GameConstants.HandStates.PalmDownRelaxed)
		end
	end,
    -- ===========================================================================================================
    -- #endregion
}
Hand.__index = Hand
return Hand