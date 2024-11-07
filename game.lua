-- Globals (because I'm lazy and no one can stop me)
GameSettings = require("Scripts.Config.GameSettings")
GameConstants = require("Scripts.Config.GameConstants")
Input = require("Scripts.Input")
Timer = require("Scripts.Timer")
HUD = require("Scripts.UI.HUD")
Common = require("Scripts.Common")


-- External Libraries
Flux = require("Scripts.libraries.flux")
Moonshine = require ("Scripts.libraries.moonshine")

-- Modals
SettingsMenu = require("Scripts.UI.SettingsMenu")

-- Scenes
local PerformScene = require("Scripts.PerformScene")
local MainMenu = require("Scripts.UI.MainMenu")
local ShopScene = require("Scripts.Scenes.ShopScene")
local RoutineBuilderScene = require("Scripts.Scenes.RoutineBuilderScene")

local PlayerStats = require("Scripts.PlayerStats")
local Logger = require("Scripts.Debug.Log")

local game = {

    Load = function(self)
        love.math.setRandomSeed(os.time())
        love.graphics.setDefaultFilter("nearest", "nearest")
		love.mouse.setVisible(true)

        Logger:Load()
		Input:Load()
		HUD:Load(PlayerStats)
        SettingsMenu:Load()
        Timer:Load()
        MainMenu:Load()
		PerformScene:Load()
        RoutineBuilderScene:Load()

        self.gameScenes =
        {
            [GameConstants.GameStates.MainMenu] = MainMenu,
            [GameConstants.GameStates.Perform] = PerformScene,
            [GameConstants.GameStates.Build] = RoutineBuilderScene,
            [GameConstants.GameStates.Shop] = ShopScene,
        }

        self:SetGameState(GameConstants.GameStates.Build)

		self.nextFixedUpdate = 0
		self.lastFixedUpdate = 0
		self.fixedUpdateStep = 1/60

        self.timerNotificationId = Timer:AddListener(self, "OnTimerFinished")

        self.vignetteEffect = Moonshine(Moonshine.effects.vignette)
        self.vignetteRadius = 0
        self.vignetteOpacity = 1
        self:FadeToScene(1)
    end,

    Update = function(self, dt)
        Input:Update()
        SettingsMenu:Update(dt)

        if SettingsMenu:GetActive() then
            return
        end

		Flux.update(dt)
		Timer:Update(dt)

        local gameScene = self:GetCurrentGameScene()
		if gameScene.Update then
			gameScene:Update(dt)
        end

		local currentTime = love.timer.getTime()
		if currentTime >= self.nextFixedUpdate then
			self:FixedUpdate(currentTime - self.lastFixedUpdate)
			self.lastFixedUpdate = currentTime
			self.nextFixedUpdate = currentTime + self.fixedUpdateStep
		end

        self.vignetteEffect.vignette.radius = self.vignetteRadius
        self.vignetteEffect.vignette.opacity = self.vignetteOpacity
        -- self.vignetteEffect.pixelate.size = self.vignettePixelateSize
        -- self.vignetteEffect.pixelate.size = self.vignettePixelateFeedback
    end,

	FixedUpdate = function(self, dt)
        local gameScene = self:GetCurrentGameScene()
		if gameScene.FixedUpdate then
			gameScene:FixedUpdate(dt)
        end
	end,

    Draw = function(self)
        self.vignetteEffect(
            function()
                self.gameScenes[self.gameState]:Draw()
                if self.gameScenes[self.gameState].LateDraw then
                    self.gameScenes[self.gameState]:LateDraw()
                end
            end
        )
        SettingsMenu:Draw()
    end,

    OnTimerFinished = function(self, timerId)
        if timerId == "RequestGameStateChange" then
            self:SetGameState(self.nextState)
            self:FadeToScene(1)
        end
	end,

    GetCurrentGameScene = function(self)
        return self.gameScenes[self.gameState]
    end,

    RequestGameStateChange = function(self, gameState)
        self.nextState = gameState
        Timer:Start("RequestGameStateChange", 1)
        self:FadeToBlack(1)
    end,

    SetGameState = function(self, newState)
        if self.gameScenes[self.gameState] then
            self.gameScenes[self.gameState]:OnStop()
            Common.UnhookFunction(
                self.gameScenes[self.gameState],
                "OnRequestGameStateChange",
                self.gameStateChangeHookId
            )
        end

        self.gameScenes[newState]:OnStart()

        self.gameStateChangeHookId = Common.HookFunction(
            self.gameScenes[newState],
            "OnRequestGameStateChange",
            function(params)
                self:RequestGameStateChange(params.newState)
            end
        )
        self.gameState = newState
    end,

    ExitGame = function(self)
        love.window.close()
    end,

    FadeToScene = function(self, fadeDuration)
        Flux.to(self, fadeDuration, { vignetteRadius = 0.9 })
        Flux.to(self, fadeDuration, { vignetteOpacity = 0.5 })
    end,

    FadeToBlack = function(self, fadeDuration)
        Flux.to(self, fadeDuration, { vignetteRadius = 0 })
        Flux.to(self, fadeDuration, { vignetteOpacity = 1 })
    end,

}
return game