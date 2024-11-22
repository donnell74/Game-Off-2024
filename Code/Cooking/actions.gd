extends Node

# Always add to end otherwise saves will break
enum Actions {
	WAIT   = 0, # No action, no station
	DICE   = 1, # knife
	PEEL   = 2, # peeler
	BOIL   = 3, # Boiling pot
	SAUTE  = 4, # sauce pan
	MASH   = 5, # masher
	MIX    = 6, # Bowl
}
