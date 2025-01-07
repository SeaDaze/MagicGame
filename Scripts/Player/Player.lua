

local RightHand = require("Scripts.Player.RightHand")
local LeftHand = require("Scripts.Player.LeftHand")
local Deck = require("Scripts.Deck")
local TechniqueCardSlot = require("Scripts.Items.Pickup.Cards.TechniqueCardSlot")
local CreditCard = require("Scripts.Items.Pickup.CreditCard")
local Inventory = require("Scripts.Player.Inventory")

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
        self.creditCard = CreditCard:New(self.leftHand, self.rightHand)

        Inventory:Load()
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

        self.cardSlotsActive = true
    end,

    OnStart = function(self)
	end,

	OnStop = function(self)
	end,

    Update = function(self, dt)
        self.deck:Update(dt)
        self.leftHand:Update(dt)
        self.rightHand:Update(dt)
        self.creditCard:Update(dt)
        Inventory:Update(dt)

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
        Inventory:Draw()

        if self.cardSlotsActive then
            for _, cardSlot in pairs(self.cardSlots) do
                cardSlot:Draw()
                local attachedCard = cardSlot:GetAttachedCard()
                if attachedCard then
                    attachedCard:Draw()
                end
                cardSlot:DrawTag()
            end
        end

        self.deck:Draw()

        if self.routineIndex and self.routine[self.routineIndex] then
            if self.routine[self.routineIndex].Draw then
                self.routine[self.routineIndex]:Draw()
            end
        end
    end,

    LateDraw = function(self)
        self.deck:LateDraw()
        if self.routineIndex and self.routine[self.routineIndex] then
            if self.routine[self.routineIndex].LateDraw then
                self.routine[self.routineIndex]:LateDraw()
            end
        end
    end,

    -- ===========================================================================================================
    -- #region [EXTERNAL]
    -- ===========================================================================================================
    OnStartPerform = function(self)
        -- Input:AddKeyListener("1", self, "EquipOne")
		-- Input:AddKeyListener("2", self, "EquipTwo")
		-- Input:AddKeyListener("3", self, "EquipThree")
		-- Input:AddKeyListener("4", self, "EquipFour")
		-- Input:AddKeyListener("5", self, "EquipFive")

        self.leftHand:OnStartPerform()
        self.rightHand:OnStartPerform()
        self.deck:OnStart()
        self:EquipDeckInLeftHand()
        self:SetRoutineIndex(1, "Fan")
        self:EquipRoutineIndex(self.equippedRoutineIndex)
    end,

    OnStopPerform = function(self)
        self.leftHand:OnStopPerform()
        self.rightHand:OnStopPerform()
    end,

    OnStartBuild = function(self)
        self.deck:SetActive(false)
        self.deck:SetVisible(false)

        self.leftHand:OnStartBuild()
        self.rightHand:OnStartBuild()
        self.cardSlotsActive = true
    end,

    OnStopBuild = function(self)
        self.leftHand:OnStopBuild()
        self.rightHand:OnStopBuild()
    end,

    OnStartShop = function(self)
        self.cardSlotsActive = false
        self.leftHand:OnStartShop()
        self.rightHand:OnStartShop()
        self.creditCard:OnStart()
    end,

    OnStopShop = function(self)
        self.leftHand:OnStopShop()
        self.rightHand:OnStopShop()
    end,

    -- ===========================================================================================================
    -- #region [INTERNAL]
    -- ===========================================================================================================

    EquipDeckInLeftHand = function(self)
        self.leftHand:SetState(GameConstants.HandStates.MechanicsGrip)
        self.deck:SetDeckInLeftHand()
    end,

    EquipRoutineIndex = function(self, index)
		if self.routineIndex == index then
            print("EquipRoutineIndex: routineIndex is already set to: ", index)
			return
		end

		if self.routineIndex and self.routine[self.routineIndex] then
			self.routine[self.routineIndex]:OnStop()
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

    GetCreditCard = function(self)
        return self.creditCard
    end,

    GetInventory = function(self)
        return Inventory
    end,

    -- ===========================================================================================================
    -- #endregion
}
return Player