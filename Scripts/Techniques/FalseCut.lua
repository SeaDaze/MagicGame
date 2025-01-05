local Technique = require("Scripts.Techniques.Technique")
local Animator = require("Scripts.libraries.anim8")

local FalseCut = {
    New = function(self, deck, leftHand, rightHand)
        local instance = setmetatable({}, self)

		instance.spriteSheet = love.graphics.newImage("Images/Animations/BasicCut.png")
		instance.grid = Animator.newGrid(64, 64, instance.spriteSheet:getWidth(), instance.spriteSheet:getHeight())
		instance.animation = Animator.newAnimation(instance.grid('1-5', 1), 0.2)
        instance.deck = deck
		instance.leftHand = leftHand
        instance.rightHand = rightHand
		instance.position = { x = (love.graphics.getWidth() / 2) - (32 * 5), y = (love.graphics.getHeight() / 2) - (32 * 5) }
		instance.name = "false cut"
		instance.visible = false
		instance.active = false
        return instance
    end,

    OnStart = function(self)
		self.timerNotificationId = Timer:AddListener(self, "OnTimerFinished")

		-- self.leftActionInputId = Input:AddActionListener(GameConstants.InputActions.Left, function()
		-- 	Timer:Start("HandsToCentre", 0.5)
		-- 	self.leftHand:Disable()
		-- 	self.rightHand:Disable()
		-- 	Flux.to(self.leftHand.position, 0.5, { x = (love.graphics.getWidth() / 2), y = (love.graphics.getHeight() / 2) } )
		-- 	Flux.to(self.rightHand.position, 0.5, { x = (love.graphics.getWidth() / 2), y = (love.graphics.getHeight() / 2) } )
		-- end)
    end,

    OnStop = function(self)
		Timer:RemoveListener(self.timerNotificationId)
		self.leftHand.visible = true
		self.rightHand.visible = true
		self.leftHand.active = true
		self.rightHand.active = true
		self.deck.visible = true
		self.visible = false
		self.active = false
    end,

    Update = function(self, dt)
		if not self.active then
			return
		end
		self.animation:update(dt)
	end,

	Draw = function(self)
		if not self.visible then
			return
		end
		self.animation:draw(self.spriteSheet, self.position.x, self.position.y, nil, 5, 5)
	end,

	OnTimerFinished = function(self, timerId)
		if timerId == "HandsToCentre" then
			self.leftHand.visible = false
			self.rightHand.visible = false
			self.deck.visible = false
			self.visible = true
			self.active = true
			Timer:Start("AfterCut", 2)
		elseif timerId == "AfterCut" then
			self.active = false
			Timer:Start("Finish", 0.5)
		elseif timerId == "Finish" then
			self.leftHand.visible = true
			self.rightHand.visible = true
			self.leftHand.active = true
			self.rightHand.active = true
			self.deck.visible = true
			self.visible = false
			self:Technique_OnFinished()
		end
	end,
}

FalseCut.__index = FalseCut
setmetatable(FalseCut, Technique)
return FalseCut