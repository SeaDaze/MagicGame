
local GameConstants = 
{
    WindowResolution = 
    {
        [1] = {
            x = 320,
            y = 180,
            scale = 1,
        },
        [2] = {
            x = 640,
            y = 360,
            scale = 2,
        },
        [3] = {
            x = 960,
            y = 540,
            scale = 3,
        },
        [4] = {
            x = 1280,
            y = 720,
            scale = 4,
        },
        [5] = {
            x = 1600,
            y = 900,
            scale = 5,
        },
        [6] = {
            x = 1920,
            y = 1080,
            scale = 5,
        },
        Max = 6,
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
        Font = love.graphics.newFont("Fonts/VCR.ttf", 22)
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
		InLeftHand = 0,
		HeldBySpectator = 1,
		ReturningToDeck = 2,
		SpinningOut = 3,
		InRightHandPinchPalmDown = 4,
		InRightHandPinchPalmUp = 5,
		Dropped = 6,
		InRightHandTableSpread = 7,
		OnTable = 8,
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
        ShopKeeper = 1,
        Player = 2,
    },
}
return GameConstants