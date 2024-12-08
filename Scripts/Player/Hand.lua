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

    OnStartShop = function(self)
        self:ConnectPickupFunctions()
	end,

	OnStopShop = function(self)
		self:DisconnectPickupFunctions()
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

		self.buildActionInputId = Input:AddActionListener(self.actionListenTarget,
			function ()
				if not table.isEmpty(self.nearbyPickups) then
					self:SetState(GameConstants.HandStates.PalmDownGrabClose)
                    local nearestPickup = self:EvaluateNearestPickup()
                    if nearestPickup then
                        nearestPickup:SetPickedUp(self)
                    end
				end
			end,
			function ()
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
		)
    end,

    DisconnectPickupFunctions = function(self)
        Input:RemoveActionListener(self.buildActionInputId)
    end,

    -- ===========================================================================================================
    -- #region [PUBLICHELPERS]
    -- ===========================================================================================================
    GetState = function(self)
        return self.state
    end,

    SetState = function(self, newState)
		self.state = newState
	end,

	SetPosition = function(self, newPosition)
        self.position = newPosition
    end,

	GetPickup = function(self)
		return self.pickup
	end,

	SetPickup = function(self, pickup)
		self.pickup = pickup
	end,

    GetPosition = function(self)
		return self.position
	end,
	
	Disable = function(self)
		self.active = false
		self.activeTween:stop()
	end,

	Enable = function(self)
		self.active = true
	end,

	AddNearbyPickup = function(self, pickup)
		if table.isEmpty(self.nearbyPickups) then
			self:SetState(GameConstants.HandStates.PalmDownGrabOpen)
		end
		table.insert(self.nearbyPickups, pickup)
	end,

	RemoveNearbyPickup = function(self, pickup)
		table.removeByValue(self.nearbyPickups, pickup)
		if table.isEmpty(self.nearbyPickups) then
			self:SetState(GameConstants.HandStates.PalmDownRelaxed)
		end
	end,

    AddNearbyBriefcase = function(self, briefcase)
        if not self.nearbyBriefcases then
            self.nearbyBriefcases = {}
        end
        table.insert(self.nearbyBriefcases, briefcase)
    end,

    RemoveNearbyBriefcase = function(self, briefcase)
        table.removeByValue(self.nearbyBriefcases, briefcase)
    end,

    -- ===========================================================================================================
    -- #endregion
}
Hand.__index = Hand
return Hand