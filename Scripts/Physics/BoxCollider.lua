
local BoxCollider = 
{
    BoxCollider_New = function(self, position, width, height, centerOffset)
        local instance = setmetatable({}, self)
        instance.parentPosition = position
        instance.width = width
        instance.height = height
        instance.centerOffset = centerOffset
        instance.position = {
            x = instance.parentPosition.x - (instance.centerOffset.x * GameSettings.WindowResolutionScale),
            y = instance.parentPosition.y - (instance.centerOffset.y * GameSettings.WindowResolutionScale),
        }
        instance.collisionListenerId = 0
        instance.otherColliders = {}
        return instance
    end,

    BoxCollider_Update = function(self, dt)
        self.position = {
            x = self.parentPosition.x - (self.centerOffset.x * GameSettings.WindowResolutionScale),
            y = self.parentPosition.y - (self.centerOffset.y * GameSettings.WindowResolutionScale),
        }
        for _, listenerData in ipairs(self.collisionListeners) do
            if not listenerData.colliding and Common:AABB(self, listenerData.otherCollider) then
                listenerData.colliding = true
                listenerData:startCollidingCallback(self, listenerData.otherCollider)
                table.insert(self.otherColliders, listenerData.otherCollider)
            elseif listenerData.colliding and not Common:AABB(self, listenerData.otherCollider) then
                listenerData.colliding = false
                listenerData:stopCollidingCallback(self, listenerData.otherCollider)
                table.removeByValue(self.otherColliders, listenerData.otherCollider)
            end
        end
    end,

    BoxCollider_DebugDraw = function(self)
        if not GameSettings.ShowColliders then
            return
        end
        love.graphics.setColor(0, 1, 0, 1)
        love.graphics.rectangle(
            "line",
            self.position.x,
            self.position.y,
            self.width,
            self.height
        )
        for _, otherCollider in pairs(self.otherColliders) do
           love.graphics.line(
                self.position.x + self.width / 2,
                self.position.y + self.height / 2,
                otherCollider.position.x + otherCollider.width / 2,
                otherCollider.position.y + otherCollider.height / 2
            )
        end
        love.graphics.setColor(1, 1, 1, 1)
    end,

    BoxCollider_AddCollisionListener = function(self, otherCollider, startCollidingCallback, stopCollidingCallback)
		if not self.collisionListeners then
			self.collisionListeners = {}
		end
		self.collisionListenerId = self.collisionListenerId + 1

		self.collisionListeners[self.collisionListenerId] =
		{
            otherCollider = otherCollider,
			startCollidingCallback = startCollidingCallback,
            stopCollidingCallback = stopCollidingCallback,
            colliding = false,
		}
    end,

    BoxCollider_RemoveCollisionListener = function(self, listenerId)
        self.collisionListeners[listenerId] = nil
    end,

    BoxCollider_ClearListeners = function(self)
        self.collisionListeners = {}
    end,

}
BoxCollider.__index = BoxCollider
return BoxCollider