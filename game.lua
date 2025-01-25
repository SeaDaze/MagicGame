-- Globals (because I'm lazy and no one can stop me)
GameSettings = require("Scripts.Config.GameSettings")
EventSystem = require("Scripts.System.EventSystem")
DrawSystem = require("Scripts.System.DrawSystem")
Input = require("Scripts.System.Input")
Timer = require("Scripts.Timer")
UniqueIds = require("Scripts.System.UniqueIds")
Log = require("Scripts.Debug.Log")

-- TODO: move to required scripts rather than globals
LuaCommon = require("Scripts.System.LuaCommon")
DrawLayers = require("Scripts.Config.DrawLayers")
GameConstants = require("Scripts.Config.GameConstants")
Sprite = require("Scripts.System.Sprite")
Common = require("Scripts.Common")
Text = require("Scripts.System.Text")
Moonshine = require ("Scripts.libraries.moonshine")

-- TODO: Change to injection
Player = require("Scripts.Player.Player")
SettingsMenu = require("Scripts.UI.SettingsMenu")
Flux = require("Scripts.libraries.flux")

-- Scenes
local PerformScene = require("Scripts.Scenes.PerformScene")
local MainMenu = require("Scripts.UI.MainMenu")
local ShopScene = require("Scripts.Scenes.ShopScene")
local RoutineBuilderScene = require("Scripts.Scenes.RoutineBuilderScene")

local game = {

    -- ===========================================================================================================
    -- #region [CORE]
    -- ===========================================================================================================
    Load = function(self)
		self:ApplyWindowPreset(4)
        love.math.setRandomSeed(os.time())
        love.graphics.setDefaultFilter("nearest", "nearest")
		love.mouse.setVisible(false)

        DrawSystem:Load()
		EventSystem:Load()
		io.open("MagicGame.log","w"):close()
		Log.outfile = "MagicGame.log"

		Input:Load()
        SettingsMenu:Load()
        Timer:Load()

        Player:Load()
        MainMenu:Load()
		PerformScene:Load()
        RoutineBuilderScene:Load()
        ShopScene:Load()

        self.gameScenes =
        {
            [GameConstants.GameStates.MainMenu] = MainMenu,
            [GameConstants.GameStates.Perform] = PerformScene,
            [GameConstants.GameStates.Build] = RoutineBuilderScene,
            [GameConstants.GameStates.Shop] = ShopScene,
        }

        self:SetGameState(GameConstants.GameStates.Perform)

		self.nextFixedUpdate = 0
		self.lastFixedUpdate = 0
		self.fixedUpdateStep = 1/60

        self.timerNotificationId = Timer:AddListener(self, "OnTimerFinished")

        self.vignetteEffect = Moonshine(Moonshine.effects.vignette)
        self.vignetteRadius = 0
        self.vignetteOpacity = 1
        self:FadeToScene(1)

		Log.High("Load: Magic game loaded")
    end,

    Update = function(self, dt)
		DrawSystem:Update(dt)
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
    end,

	FixedUpdate = function(self, dt)
        local gameScene = self:GetCurrentGameScene()
		if gameScene.FixedUpdate then
			gameScene:FixedUpdate(dt)
        end
	end,

    Draw = function(self)
        love.graphics.setBackgroundColor(0.128, 0.128, 0.136, 1)
        self.vignetteEffect(
            function()
                DrawSystem:DrawAll()
            end
        )
        SettingsMenu:Draw()
		love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
		love.graphics.print("Draw calls: "..tostring( DrawSystem.debug_DrawCalls), 10, 25)
    end,

    -- ===========================================================================================================
    -- #region [INTERNAL]
    -- ===========================================================================================================

	ApplyWindowPreset = function(self, preset)
		local windowResolution = GameConstants.WindowResolution[preset]
		love.window.setMode(windowResolution.x, windowResolution.y)
		GameSettings.WindowResolutionScale = windowResolution.scale
	end,

    FadeToScene = function(self, fadeDuration)
        Flux.to(self, fadeDuration, { vignetteRadius = 0.9 })
        Flux.to(self, fadeDuration, { vignetteOpacity = 0.5 })
    end,

    FadeToBlack = function(self, fadeDuration)
        Flux.to(self, fadeDuration, { vignetteRadius = 0 })
        Flux.to(self, fadeDuration, { vignetteOpacity = 1 })
    end,

    -- Game State
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
        end

        self.gameScenes[newState]:OnStart()

        self.gameState = newState
    end,

}
return game