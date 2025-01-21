
local BoxCollider = 
{
    BoxCollider_New = function(self, owner, position, width, height, originOffsetRatio, windowScaleFraction)
        local instance = setmetatable({}, self)
        instance.parentPosition = position
        instance.windowScaleFraction = windowScaleFraction or 1
        instance.width = width * GameSettings.WindowResolutionScale / instance.windowScaleFraction
        instance.height = height * GameSettings.WindowResolutionScale / instance.windowScaleFraction
        instance.originOffsetRatio = originOffsetRatio
        
        instance.position = {
            x = instance.parentPosition.x - (instance.width * instance.originOffsetRatio.x),
            y = instance.parentPosition.y - (instance.height * instance.originOffsetRatio.y),
        }
        instance.collisionListenerId = 0
        instance.otherColliders = {}
        instance.collisionListeners = {}
		instance.pointCollisionListeners = {}
        instance.owner = owner
        instance.active = false

        DrawSystem:AddDebugDraw(
            function ()
                if not instance.active then
                    return
                end
                love.graphics.setColor(0, 1, 0, 1)
                love.graphics.rectangle(
                    "line",
                    instance.position.x,
                    instance.position.y,
                    instance.width,
                    instance.height
                )
                for _, otherCollider in pairs(instance.otherColliders) do
                   love.graphics.line(
                        instance.position.x + instance.width / 2,
                        instance.position.y + instance.height / 2,
                        otherCollider.position.x + otherCollider.width / 2,
                        otherCollider.position.y + otherCollider.height / 2
                    )
                end
                love.graphics.setColor(1, 1, 1, 1)
            end
        )
        return instance
    end,

    BoxCollider_OnStart = function(self)
        self.active = true
    end,

    BoxCollider_OnStop = function(self)
        self.active = false
    end,

    BoxCollider_Update = function(self, dt)
        if not self.active then
            return
        end
        self.position = {
            x = self.parentPosition.x - (self.width * self.originOffsetRatio.x),
            y = self.parentPosition.y - (self.height * self.originOffsetRatio.y),
        }
        for _, listenerData in ipairs(self.collisionListeners) do
            if self.active and listenerData.otherCollider:BoxCollider_GetActive() then
                if not listenerData.colliding and Common:AABB(self, listenerData.otherCollider) then
                    listenerData.colliding = true
                    listenerData.startCollidingCallback(self, listenerData.otherCollider)
                    table.insert(self.otherColliders, listenerData.otherCollider)
                elseif listenerData.colliding and not Common:AABB(self, listenerData.otherCollider) then
                    listenerData.colliding = false
                    listenerData.stopCollidingCallback(self, listenerData.otherCollider)
                    table.removeByValue(self.otherColliders, listenerData.otherCollider)
                end
            end
        end
		for _, listenerData in ipairs(self.pointCollisionListeners) do
            if self.active and listenerData.targetVector3Reference then
				Log.High("listenerData.targetVector3Reference = ", listenerData.targetVector3Reference)
                if not listenerData.colliding and Common:PointCollision(self, listenerData.targetVector3Reference) then
                    listenerData.colliding = true
                    listenerData.startCollidingCallback(self)
                elseif listenerData.colliding and not Common:PointCollision(self, listenerData.targetVector3Reference) then
                    listenerData.colliding = false
                    listenerData.stopCollidingCallback(self)
                end
            end
        end
    end,

	BoxCollider_AddPointCollisionListener = function(self, targetVector3Reference, startCollidingCallback, stopCollidingCallback)
		self.collisionListenerId = self.collisionListenerId + 1
		self.pointCollisionListeners[self.collisionListenerId] =
		{
            targetVector3Reference = targetVector3Reference,
			startCollidingCallback = startCollidingCallback,
            stopCollidingCallback = stopCollidingCallback,
            colliding = false,
		}
        return self.collisionListenerId
    end,

    BoxCollider_RemovePointCollisionListener = function(self, listenerId)
        self.collisionListeners[listenerId] = nil
    end,

    BoxCollider_AddCollisionListener = function(self, otherCollider, startCollidingCallback, stopCollidingCallback)
		self.collisionListenerId = self.collisionListenerId + 1
		self.collisionListeners[self.collisionListenerId] =
		{
            otherCollider = otherCollider,
			startCollidingCallback = startCollidingCallback,
            stopCollidingCallback = stopCollidingCallback,
            colliding = false,
		}
        return self.collisionListenerId
    end,

    BoxCollider_RemoveCollisionListener = function(self, listenerId)
        self.collisionListeners[listenerId] = nil
    end,

    BoxCollider_ClearListeners = function(self)
        self.collisionListeners = {}
    end,

    BoxCollider_GetOwner = function(self)
        return self.owner
    end,

    BoxCollider_SetScaleModifier = function(self, scaleModifier)
        self.width = self.width * scaleModifier.x
        self.height = self.height * scaleModifier.y
    end,

    BoxCollider_GetActive = function(self)
        return self.active
    end,
}
BoxCollider.__index = BoxCollider
return BoxCollider