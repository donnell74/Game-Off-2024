extends Node

# Always add to end otherwise saves will break
enum Actions {
	WAIT   = 0, # No action, no station
	DICE   = 1, # cutting board
	PEEL   = 2, # cutting board
	BOIL   = 3, # cooking pot
	SAUTE  = 4, # cooking pot
	SIMMER = 5, # cooking pot
	MELT   = 6, # cooking pot
	MASH   = 7, # cooking pot
	CHOP   = 8, # cutting board
	MIX    = 9, # cooking pot
}
