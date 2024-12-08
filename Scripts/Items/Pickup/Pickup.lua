local BoxCollider = require("Scripts.Physics.BoxCollider")

local Pickup = 
{
    Pickup_Initialize = function(self, leftHand, rightHand)
        self.position = { x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2 }
        self.spriteWidth = self.sprite:getWidth()
		self.spriteHeight = self.sprite:getHeight()
        self.width = self.spriteWidth * GameSettings.WindowResolutionScale
        self.height = self.spriteHeight * GameSettings.WindowResolutionScale
        self.centerOffset = { x = self.spriteWidth / 2, y = self.spriteHeight / 2 }
        self.angle = 0
        local longestEdge = math.max(self.spriteWidth, self.spriteHeight)
        self.pickupDistance = longestEdge * longestEdge * GameSettings.WindowResolutionScale

        self.windowScaleFraction = 1
        self.leftHand = leftHand
        self.rightHand = rightHand
        self.hoveredRight = false
        self.hoveredLeft = false
        self.heldOffset = { x = 0, y = 0 }
        self.droppedListenerId = 1
        self.pickupListenerId = 1

        self.pickedUp = false

        self.collider = BoxCollider:BoxCollider_New(self.position, self.width, self.height, self.centerOffset)
    end,

    OnStart = function(self)
        self:Pickup_OnStart()
    end,

    Pickup_OnStart = function(self)
    end,

    OnStop = function(self)
        self:Pickup_OnStop()
    end,

    Pickup_OnStop = function(self)
        self.collider:BoxCollider_ClearListeners()
    end,

    Update = function(self, dt)
        self:HandleRightHand()
        self:HandleLeftHand()
        self.collider:BoxCollider_Update()
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
        self.collider:BoxCollider_DebugDraw()
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

    SetPickedUp = function(self, hand)
        if self.pickedUp then
            return
        end
        self.heldOffset = 
        {
            x = self.position.x - hand:GetPosition().x,
            y = self.position.y - hand:GetPosition().y,
        }
        for _, pickupListener in pairs(self.pickupListeners) do
            pickupListener:callback(self)
        end
        self.pickedUp = true
        hand:SetPickup(self)
    end,

    SetDropped = function(self, hand)
        if not self.pickedUp then
            return
        end
        for _, droppedListener in pairs(self.droppedListeners) do
            droppedListener:callback(self)
        end
        self.pickedUp = false
        hand:SetPickup(nil)
    end,

    GetCollider = function(self)
        return self.collider
    end,
}
Pickup.__index = Pickup
return Pickup