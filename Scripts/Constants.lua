local GameConstants = 
{
    GameStates = 
    {
        MainMenu = 0,
        Perform = 1,
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
		MechanicsGrip = 0,
		Fan = 1,
	},

	HandStates = 
	{
		PalmDown = 0,
		PalmDownPinch = 1,
		PalmDownIndexOut = 2,
		PalmUp = 3,
		PalmUpPinch = 4,
		PalmDownTableSpread = 5,
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
	}
}
return GameConstants