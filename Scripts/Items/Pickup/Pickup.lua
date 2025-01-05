local BoxCollider = require("Scripts.Physics.BoxCollider")
local EventIds    = require("Scripts.System.EventIds")

local Pickup = 
{
    Pickup_Initialize = function(self, leftHand, rightHand, windowScaleFraction)
        self.windowScaleFraction = windowScaleFraction or 1
        self.pickupDistance = 10000

        self.leftHand = leftHand
        self.rightHand = rightHand
        self.hoveredRight = false
        self.hoveredLeft = false
        self.heldOffset = { x = 0, y = 0 }
        self.droppedListenerId = 1
        self.pickupListenerId = 1
        self.pickupListeners = {}
        self.droppedListeners = {}
        self.pickedUp = false

        self.value = 10
        self.collider = BoxCollider:BoxCollider_New(self, self.sprite.position, self.sprite.width, self.sprite.height, { x = 0.5, y = 0.5 }, self.windowScaleFraction)

        self.active = false
    end,

    OnStart = function(self)
        self:Pickup_OnStart()
    end,

    Pickup_OnStart = function(self)
        DrawSystem:AddDrawable(self.sprite)
        self.collider:BoxCollider_OnStart()
        self.active = true
    end,

    OnStop = function(self)
        self:Pickup_OnStop()
        self.active = false
    end,

    Pickup_OnStop = function(self)
        self.collider:BoxCollider_ClearListeners()
        DrawSystem:RemoveDrawable(self.sprite)
    end,

    Update = function(self, dt)
        self.collider:BoxCollider_Update()
        if not self.active then
            return
        end
        self:HandleRightHand()
        self:HandleLeftHand()
    end,

    HandleRightHand = function(self)
        local rightHandPosition = self.rightHand:GetPosition()
        local withinRange = Common:DistanceSquared(self.sprite.position.x, self.sprite.position.y, rightHandPosition.x, rightHandPosition.y) < self.pickupDistance
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
        local withinRange = Common:DistanceSquared(self.sprite.position.x, self.sprite.position.y, handPosition.x, handPosition.y) < self.pickupDistance
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
        self.collider:BoxCollider_DebugDraw()
    end,

    SetPosition = function(self, newPosition, offset)
        offset = offset or {x = 0, y = 0}
        self.sprite.position.x = newPosition.x + offset.x
        self.sprite.position.y = newPosition.y + offset.y
        self.sprite.position.z = newPosition.z
    end,

    GetPosition = function(self)
        return self.sprite.position
    end,

    SetPickedUp = function(self, hand)
        if self.pickedUp then
            return
        end
        self.heldOffset = 
        {
            x = self.sprite.position.x - hand:GetPosition().x,
            y = self.sprite.position.y - hand:GetPosition().y,
        }

		EventSystem:BroadcastEvent(EventIds.ItemPickedUp, self)

        self.pickedUp = true
        hand:SetPickup(self)
    end,

    SetDropped = function(self, hand)
        if not self.pickedUp then
            return
        end

		EventSystem:BroadcastEvent(EventIds.ItemDropped, self)

        self.pickedUp = false
        self.sprite.position.z = 3
        hand:SetPickup(nil)
    end,

    GetCollider = function(self)
        return self.collider
    end,

    GetValue = function(self)
        return self.value
    end,

    SetActive = function(self, isActive)
        self.rightHand:RemoveNearbyPickup(self)
        self.leftHand:RemoveNearbyPickup(self)
        self.active = isActive
    end,

	SetItemOwner = function(self, newOwner)
        self.itemOwner = newOwner
    end,

    GetItemOwner = function(self)
        return self.itemOwner
    end,

    GetSprite = function(self)
        return self.sprite
    end,
}
Pickup.__index = Pickup
return Pickup