local Hand = 
{
    OnStartBuild = function(self)
		self:SetState(GameConstants.HandStates.PalmDownRelaxed)

		self.buildActionInputId = Input:AddActionListener(self.actionListenTarget,
			function ()
				if not table.isEmpty(self.nearbyPickups) then
					self:SetState(GameConstants.HandStates.PalmDownGrabClose)
				end
			end,
			function ()
				if table.isEmpty(self.nearbyPickups) then
					self:SetState(GameConstants.HandStates.PalmDownRelaxed)
				else
					self:SetState(GameConstants.HandStates.PalmDownGrabOpen)
				end
			end
		)
	end,

	OnStopBuild = function(self)
		Input:RemoveActionListener(self.buildActionInputId)
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
}
Hand.__index = Hand
return Hand