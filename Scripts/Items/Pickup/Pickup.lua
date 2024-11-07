

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
        self.attachedToRightHand = false
        self.hoveredLeft = false
        self.attachedToLeftHand = false
        self.heldOffset = { x = 0, y = 0 }
        self.droppedListenerId = 1
        self.pickupListenerId = 1
    end,

    OnStart = function(self)
        self:Pickup_OnStart()
    end,

    Pickup_OnStart = function(self)
        self.leftActionInputId = Input:AddActionListener(GameConstants.InputActions.Left,
            function ()
                if self.hoveredLeft and not self.attachedToLeftHand then
                    self.attachedToLeftHand = true
                    self.heldOffset = 
                    {
                        x = self.position.x - self.leftHand:GetPosition().x,
                        y = self.position.y - self.leftHand:GetPosition().y,
                    }
                    for _, pickupListener in pairs(self.pickupListeners) do
                        pickupListener:callback(self)
                    end
                end
            end,
            function ()
                if self.attachedToLeftHand then
                    self.attachedToLeftHand = false
                    for _, droppedListener in pairs(self.droppedListeners) do
                        droppedListener:callback(self)
                    end
                end
            end
        )

        self.rightActionInputId = Input:AddActionListener(GameConstants.InputActions.Right,
            function ()
                if self.hoveredRight and not self.attachedToRightHand then
                    self.attachedToRightHand = true
                    self.heldOffset = 
                    {
                        x = self.position.x - self.rightHand:GetPosition().x,
                        y = self.position.y - self.rightHand:GetPosition().y,
                    }
                    for _, pickupListener in pairs(self.pickupListeners) do
                        pickupListener:callback(self)
                    end
                end
            end,
            function ()
                if self.attachedToRightHand then
                    self.attachedToRightHand = false
                    for _, droppedListener in pairs(self.droppedListeners) do
                        droppedListener:callback(self)
                    end
                end
            end
        )

        print("Pickup: OnStart")
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
        elseif not withinRange and self.hoveredRight then
            self.hoveredRight = false
        end

        if self.attachedToRightHand then
            self:SetPosition(rightHandPosition, self.heldOffset)
        end
    end,

    HandleLeftHand = function(self)
        local handPosition = self.leftHand:GetPosition()
        local withinRange = Common:DistanceSquared(self.position.x, self.position.y, handPosition.x, handPosition.y) < self.pickupDistance
        if withinRange and not self.hoveredLeft then
            self.hoveredLeft = true
        elseif not withinRange and self.hoveredLeft then
            self.hoveredLeft = false
        end

        if self.attachedToLeftHand then
            self:SetPosition(handPosition, self.heldOffset)
        end
    end,

    Draw = function(self)
        if self.hoveredLeft or self.hoveredRight then
            love.graphics.setBlendMode("add", "premultiplied")
        end
        love.graphics.draw(
            self.sprite,
            self.position.x,
            self.position.y,
            math.rad(self.angle),
            GameSettings.WindowResolutionScale / self.windowScaleFraction,
            GameSettings.WindowResolutionScale / self.windowScaleFraction,
            self.spriteWidth / 2,
            self.spriteHeight / 2
        )
        love.graphics.setBlendMode("alpha")
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