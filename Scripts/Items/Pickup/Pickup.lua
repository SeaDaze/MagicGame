

local Pickup = 
{
    Pickup_Initialize = function(self, leftHand, rightHand)
        self.position = { x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2 }
        self.spriteWidth = self.sprite:getWidth()
		self.spriteHeight = self.sprite:getHeight()
        self.angle = 0
        local longestEdge = math.max(self.spriteWidth, self.spriteHeight)
        self.pickupDistance = longestEdge * longestEdge

        self.windowScaleFraction = 1
        self.leftHand = leftHand
        self.rightHand = rightHand
        self.hoveredRight = false
        self.hoveredLeft = false
        self.heldOffset = { x = 0, y = 0 }
        self.droppedListenerId = 1
        self.pickupListenerId = 1

        self.pickedUp = false
    end,

    OnStart = function(self)
        self:Pickup_OnStart()
    end,

    Pickup_OnStart = function(self)
        self.leftActionInputId = Input:AddActionListener(GameConstants.InputActions.Left,
            function ()
                if self.hoveredLeft and not self.leftHand:GetPickup() then
                    self.leftHand:SetPickup(self)
                    self.heldOffset = 
                    {
                        x = self.position.x - self.leftHand:GetPosition().x,
                        y = self.position.y - self.leftHand:GetPosition().y,
                    }
                    for _, pickupListener in pairs(self.pickupListeners) do
                        pickupListener:callback(self)
                    end
                    self.pickedUp = true
                end
            end,
            function ()
                if self.leftHand:GetPickup() == self then
                    self.leftHand:SetPickup(nil)
                    for _, droppedListener in pairs(self.droppedListeners) do
                        droppedListener:callback(self)
                    end
                    self.pickedUp = false
                end
            end
        )

        self.rightActionInputId = Input:AddActionListener(GameConstants.InputActions.Right,
            function ()
                if self.hoveredRight and not self.rightHand:GetPickup() then
                    self.rightHand:SetPickup(self)
                    self.heldOffset = 
                    {
                        x = self.position.x - self.rightHand:GetPosition().x,
                        y = self.position.y - self.rightHand:GetPosition().y,
                    }
                    for _, pickupListener in pairs(self.pickupListeners) do
                        pickupListener:callback(self)
                    end
                    self.pickedUp = true
                end
            end,
            function ()
                if self.rightHand:GetPickup() == self then
                    self.rightHand:SetPickup(nil)
                    for _, droppedListener in pairs(self.droppedListeners) do
                        droppedListener:callback(self)
                    end
                    self.pickedUp = false
                end
            end
        )
    end,

    OnStop = function(self)
        self:Pickup_OnStop()
    end,

    Pickup_OnStop = function(self)
        Input:RemoveActionListener(self.leftActionInputId)
        Input:RemoveActionListener(self.rightActionInputId)
    end,

    Update = function(self, dt)
        self:HandleRightHand()
        self:HandleLeftHand()
    end,

    HandleRightHand = function(self)
        local rightHandPosition = self.rightHand:GetPosition()
        local withinRange = Common:DistanceSquared(self.position.x, self.position.y, rightHandPosition.x, rightHandPosition.y) < self.pickupDistance
        if withinRange and not self.hoveredRight then
            self.hoveredRight = true
            self.rightHand:AddNearbyPickup(self)
        elseif not withinRange and self.hoveredRight then
            self.hoveredRight = false
            self.rightHand:RemoveNearbyPickup(self)
        end

        if self.rightHand:GetPickup() == self then
            self:SetPosition(rightHandPosition, self.heldOffset)
        end
    end,

    HandleLeftHand = function(self)
        local handPosition = self.leftHand:GetPosition()
        local withinRange = Common:DistanceSquared(self.position.x, self.position.y, handPosition.x, handPosition.y) < self.pickupDistance
        if withinRange and not self.hoveredLeft then
            self.hoveredLeft = true
            self.leftHand:AddNearbyPickup(self)
        elseif not withinRange and self.hoveredLeft then
            self.hoveredLeft = false
            self.leftHand:RemoveNearbyPickup(self)
        end

        if self.leftHand:GetPickup() == self then
            self:SetPosition(handPosition, self.heldOffset)
        end
    end,

    Draw = function(self)
        local scale = GameSettings.WindowResolutionScale / self.windowScaleFraction
        if self.pickedUp then
            scale = scale * 1.05
        end
        love.graphics.draw(
            self.sprite,
            self.position.x,
            self.position.y,
            math.rad(self.angle),
            scale,
            scale,
            self.spriteWidth / 2,
            self.spriteHeight / 2
        )
    end,

    SetPosition = function(self, newPosition, offset)
        offset = offset or {x = 0, y = 0}
        self.position.x = newPosition.x + offset.x
        self.position.y = newPosition.y + offset.y
    end,

    GetPosition = function(self)
        return self.position
    end,

    AddPickupListener = function(self, callback)
		if not self.pickupListeners then
			self.pickupListeners = {}
		end
		self.pickupListenerId = self.pickupListenerId + 1

		self.pickupListeners[self.pickupListenerId] =
		{
			callback = callback,
		}
	end,

    RemovePickupListener = function(self, listenerId)
        self.pickupListeners[listenerId] = nil
    end,

    AddDroppedListener = function(self, callback)
		if not self.droppedListeners then
			self.droppedListeners = {}
		end
		self.droppedListenerId = self.droppedListenerId + 1

		self.droppedListeners[self.droppedListenerId] =
		{
			callback = callback,
		}
	end,

    RemoveDroppedListener = function(self, listenerId)
        self.droppedListeners[listenerId] = nil
    end,
}
Pickup.__index = Pickup
return Pickup