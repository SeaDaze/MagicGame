
local GameConstants = 
{
    WindowResolution = 
    {
        [1] = {
            x = 640,
            y = 360,
            scale = 1,
        },
        [2] = {
            x = 960,
            y = 540,
            scale = 1.5,
        },
        [3] = {
            x = 1280,
            y = 720,
            scale = 2,
        },
        [4] = {
            x = 1600,
            y = 900,
            scale = 2.5,
        },
        [5] = {
            x = 1920,
            y = 1080,
            scale = 3,
        },
		[6] = {
            x = 540,
            y = 960,
            scale = 1.5,
        },
        Max = 5,
    },

    UI = {
        Anchor = 
        {
            Left = 0,
            Right = 1,
            Top = 2,
            Bottom = 3,
        },
        BasicButtonType = 
        {
            Rectangle = 0,
            Square = 1,
        },
        Font = love.graphics.newFont("Fonts/VCR.ttf", 22),
        FontAlt = love.graphics.newFont("Fonts/pixelifySans.ttf", 30),
    },

    GameStates = 
    {
        MainMenu = 0,
        Perform = 1,
        Shop = 2,
        Build = 3,
    },

	CardStates = 
	{
		InLeftHandDefault = 0,
		HeldBySpectator = 1,
		ReturningToDeck = 2,
		SpinningOut = 3,
		InRightHandPinchPalmDown = 4,
		InRightHandPinchPalmUp = 5,
		Dropped = 6,
		InRightHandTableSpread = 7,
		OnTable = 8,
		InLeftHandFanning = 9,
	},

	HandStates = 
	{
		PalmDown = 1,
		PalmDownPinch = 2,
		PalmDownIndexOut = 3,
		PalmUp = 4,
		PalmUpPinch = 5,
		PalmDownTableSpread = 6,
        PalmDownNatural = 7,
        PalmDownGrabOpen = 8,
        PalmDownGrabClose = 9,
        PalmDownRelaxed = 10,
        PalmDownRelaxedIndexOut = 11,
        MechanicsGrip = 12,
        Fan = 13,
		PalmDownRelaxedIndexPressed = 14,
		DuckChangeSqueeze = 15,
	},

	CardSuits = 
	{
		Spades = 1,
		Hearts = 2,
		Clubs = 3,
		Diamonds = 4
	},

	CardDimensions = 
	{
		Width = 88,
        Height = 124,
	},

    JoystickAxis = 
    {
        LeftStick = 
        {
            X = "leftx",
            Y = "lefty",
        },
        RightStick = 
        {
            X = "rightx",
            Y = "righty",
        },
        LeftTrigger = "triggerleft",
        RightTrigger = "triggerright"
    },

    InputAxis = 
    {
        Left = 
        {
            X = 1,
            Y = 2,
        },
        Right =
        {
            X = 3,
            Y = 4,
        }
    },

    InputActions = 
    {
        Left = 1,
        Right = 2,
    },

    JoystickInputDeadzone = 0.2,

    ItemOwners = 
    {
        None = 1,
        ShopKeeper = 2,
        Player = 3,
    },

    DrawableTypes = 
    {
        Sprite = 1,
        Text = 2,
        SpritesheetQuad = 3,
		ComplexSpritesheetQuad = 4,
		ParticleSystem = 5,
		SpriteBatch = 6,
    },

	AudienceFaceIndex = 
	{
		Neutral = 1,
		Suspicious = 2,
		Awe = 3,
		Scared = 4,
		Happy = 5,
		ScaryHappy = 6,
		Angry = 7,
	}
}
return GameConstants