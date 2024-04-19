local Constants = 
{
    GameStates = 
    {
        MainMenu = 0,
        Perform = 1,
		Streets = 2,
    },

	CardStates = 
	{
		InDeck = 0,
		HeldBySpectator = 1,
		ReturningToDeck = 2,
		SpinningOut = 3,
		InRightHand = 4,
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
return Constants