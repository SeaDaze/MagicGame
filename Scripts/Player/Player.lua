

local RightHand = require("Scripts.Player.RightHand")
local LeftHand = require("Scripts.Player.LeftHand")
local Deck = require("Scripts.Deck")
local TechniqueCardSlot = require("Scripts.Items.Pickup.Cards.TechniqueCardSlot")

local Techniques = 
{
    CardShootCatch = require ("Scripts.Tricks.CardShootCatch"),
    DoubleLift = require("Scripts.Techniques.DoubleLift"),
    CardiniChange = require("Scripts.Tricks.CardiniChange"),
    TableSpread   = require("Scripts.Techniques.TableSpread"),
    Fan = require("Scripts.Techniques.Fan"),
    FalseCut = require("Scripts.Techniques.FalseCut"),
}

local Player = 
{
    -- ===========================================================================================================
    -- #region [CORE]
    -- ===========================================================================================================
    Load = function(self)
        self.leftHand = LeftHand:New()
        self.rightHand = RightHand:New()
		self.deck = Deck:New(self.leftHand, self.rightHand)

        self.techniques = {}
        self.routine = {}
        self.actionListeners = {}
        self.actionListenerId = 0
        self.equippedRoutineIndex = 1

        local cardSlotSprites = {
            slot = love.graphics.newImage("Images/Cards/TechniqueCards/technique_CardSlot.png"),
            selected = love.graphics.newImage("Images/Cards/TechniqueCards/technique_Selected.png"),
            completed = love.graphics.newImage("Images/Cards/TechniqueCards/technique_Complete.png"),
        }
        local cardSlotWidth = cardSlotSprites.slot:getWidth()
        local cardSlotHeight = cardSlotSprites.slot:getHeight()

        self.cardSlots = {
            TechniqueCardSlot:New(1, cardSlotSprites, { x = (love.graphics.getWidth() / 2) - (cardSlotWidth * 4), y = love.graphics.getHeight() -  (cardSlotHeight * 2) }),
            TechniqueCardSlot:New(2, cardSlotSprites, { x = (love.graphics.getWidth() / 2) - (cardSlotWidth * 2), y = love.graphics.getHeight() -  (cardSlotHeight * 2) }),
            TechniqueCardSlot:New(3, cardSlotSprites, { x = (love.graphics.getWidth() / 2), y = love.graphics.getHeight() -  (cardSlotHeight * 2) }),
            TechniqueCardSlot:New(4, cardSlotSprites, { x = (love.graphics.getWidth() / 2) + (cardSlotWidth * 2), y = love.graphics.getHeight() -  (cardSlotHeight * 2) }),
            TechniqueCardSlot:New(5, cardSlotSprites, { x = (love.graphics.getWidth() / 2) + (cardSlotWidth * 4), y = love.graphics.getHeight() -  (cardSlotHeight * 2) }),
        }
    end,

    OnStart = function(self)
	end,

	OnStop = function(self)
	end,

    Update = function(self, dt)
        self.deck:Update(dt)
        self.leftHand:Update(dt)
        self.rightHand:Update(dt)

        if self.routineIndex and self.routine[self.routineIndex] then
            if self.routine[self.routineIndex].Update then
                self.routine[self.routineIndex]:Update(dt)
            end
        end
    end,

    FixedUpdate = function(self, dt)
        self.deck:FixedUpdate(dt)
        self.leftHand:FixedUpdate(dt)
        self.rightHand:FixedUpdate(dt)

        if self.routineIndex and self.routine[self.routineIndex] then
            if self.routine[self.routineIndex].FixedUpdate then
                self.routine[self.routineIndex]:FixedUpdate(dt)
            end
        end
	end,

    Draw = function(self)
        for _, cardSlot in pairs(self.cardSlots) do
            cardSlot:Draw()
            local attachedCard = cardSlot:GetAttachedCard()
			if attachedCard then
				attachedCard:Draw()
			end
            cardSlot:DrawTag()
        end

        self.leftHand:Draw()
        self.rightHand:Draw()
        self.deck:Draw()

        if self.routineIndex and self.routine[self.routineIndex] then
            if self.routine[self.routineIndex].Draw then
                self.routine[self.routineIndex]:Draw()
            end
        end
    end,

    LateDraw = function(self)
        self.deck:LateDraw()
        self.leftHand:LateDraw()
        self.rightHand:LateDraw()
    end,

    -- ===========================================================================================================
    -- #region [EXTERNAL]
    -- ===========================================================================================================
    OnStartPerform = function(self)
        Input:AddKeyListener("1", self, "EquipOne")
		Input:AddKeyListener("2", self, "EquipTwo")
		Input:AddKeyListener("3", self, "EquipThree")
		Input:AddKeyListener("4", self, "EquipFour")
		Input:AddKeyListener("5", self, "EquipFive")

        self.leftHand:SetState(GameConstants.HandStates.MechanicsGrip)
        self.deck:SetActive(true)
        self.deck:SetVisible(true)
        self:EquipRoutineIndex(self.equippedRoutineIndex)
    end,

    OnStopPerform = function(self)
    end,

    OnStartBuild = function(self)
        self.deck:SetActive(false)
        self.deck:SetVisible(false)

        self.leftHand:OnStartBuild()
        self.rightHand:OnStartBuild()
    end,

    OnStopBuild = function(self)
        self.leftHand:OnStopBuild()
        self.rightHand:OnStopBuild()
    end,

    AddActionListener = function(self, action, callback)
		if not self.actionListeners[action] then
			self.actionListeners[action] = {}
		end
		self.actionListenerId = self.actionListenerId + 1
		if not self.listenerIdToAction then
			self.listenerIdToAction = {}
		end
		self.listenerIdToAction[self.actionListenerId] = action

		self.actionListeners[action][self.actionListenerId] = callback
        return self.actionListenerId
	end,

    RemoveActionListener = function(self, listenerId)
		local action = self.listenerIdToAction[listenerId]
		if not action then
			print("RemoveActionListener: No action found with listenerId=", listenerId)
			return
		end
		if self.actionListeners[action][listenerId] then
			self.actionListeners[action][listenerId] = nil
		end
	end,

    -- ===========================================================================================================
    -- #region [INTERNAL]
    -- ===========================================================================================================
    EquipRoutineIndex = function(self, index)
		if self.routineIndex == index then
            print("EquipRoutineIndex: routineIndex is already set to: ", index)
			return
		end

		if self.routineIndex and self.routine[self.routineIndex] then
			self.routine[self.routineIndex]:OnStop()
            self.routine[self.routineIndex]:Technique_RemoveActionListener("Technique_OnTechniqueEvaluated", self.onTechniqueEvaluatedHookId)
            self.routine[self.routineIndex]:Technique_RemoveActionListener("Technique_OnFinished", self.onTechniqueFinishedHookId)
            self.cardSlots[self.routineIndex]:SetCompleted()
            print("EquipRoutineIndex: Completed=", self.routineIndex)
		end

        if self.routine[index] == nil then
            print("EquipRoutineIndex: No technique initialised at routineIndex=", index)
			return
		end

        print("EquipRoutineIndex: index=", index)
		self.routineIndex = index
		self.routine[self.routineIndex]:OnStart()
        self.cardSlots[self.routineIndex]:SetSelected()
		self.onTechniqueEvaluatedHookId = self.routine[self.routineIndex]:Technique_AddActionListener("Technique_OnTechniqueEvaluated", function(params)
            local actionCallbacks = self.actionListeners["OnTechniqueEvaluated"]
			if actionCallbacks then
                for _, callback in pairs(actionCallbacks) do
                    callback(params.score)
                end
            end
		end)
        self.onTechniqueFinishedHookId = self.routine[self.routineIndex]:Technique_AddActionListener("Technique_OnFinished", function(params)
            self:EquipRoutineIndex(self.routineIndex + 1)
		end)
	end,

    EquipOne = function(self)
		self:EquipRoutineIndex(1)
	end,

	EquipTwo = function(self)
		self:EquipRoutineIndex(2)
	end,

	EquipThree = function(self)
		self:EquipRoutineIndex(3)
	end,

	EquipFour = function(self)
		self:EquipRoutineIndex(4)
	end,

	EquipFive = function(self)
		self:EquipRoutineIndex(5)
	end,

    -- ===========================================================================================================
    -- #region [PUBLICHELPERS]
    -- ===========================================================================================================
    GetLeftHand = function(self)
        return self.leftHand
    end,

    GetRightHand = function(self)
        return self.rightHand
    end,

    GetDeck = function(self)
        return self.deck
    end,

    SetRoutineIndex = function(self, index, typeId)
        if typeId then
            if not self.techniques[typeId] then
                self.techniques[typeId] = Techniques[typeId]:New(self.deck, self.leftHand, self.rightHand)
                print("SetRoutineIndex: Created new technique with Id=", typeId, ", index=", index)
            end
            self.routine[index] = self.techniques[typeId]
            print("SetRoutineIndex: self.routine[index]=", self.routine[index])
            print("SetRoutineIndex: Set technique with Id=", typeId, ", to index=", index)
        else
            self.routine[index] = nil
            print("SetRoutineIndex: Set index=", index, " to nil")
        end
    end,

    SetRoutine = function(self, routine)
        self.routine = routine
    end,

    GetRoutine = function(self)
        return self.routine
    end,

    GetCardSlots = function(self)
        return self.cardSlots
    end,

    -- ===========================================================================================================
    -- #endregion
}
return Player