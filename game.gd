extends Node2D

const DIRECTIONS = ["N", "E", "S", "W"]

const MAP = {
	"N": "COAST",
	"E": "LIGHT",
	"S": "PORT",
	"W": "RIVER"
}

const MISSPELLINGS = {
	"N": ["COST", "COSTA", "COASTS", "CAOST", "COATS"],
	"E": ["LHOUSE", "LITE", "LIT", "LIHGT", "LGHT"],
	"S": ["POTR", "PRTO", "PORTS", "POTRS", "POR"],
	"W": ["RIEVR", "RIVR", "RIVAR", "RIO", "RIVIERA"]
}

var boat = {
	"course": "",
	"is_legit": 1,
	"mispelling": "",
}

@onready var morse_receiver: Node2D = $MorseReceiver
@onready var morse_encoder: Node2D = $MorseEncoder
@onready var score_label: Label = $Score

var score := 0 

func _ready() -> void:
	get_new_boat()

func get_new_boat() -> void:
	"""
	Creates a new boat with a random course and legitimacy.
	"""
	boat = {
		"course": DIRECTIONS[randi() % DIRECTIONS.size()],
		"is_legit": randi() % 2 == 0,
		"mispelling": ""
	}

	if not boat.is_legit:
		boat.mispelling = MISSPELLINGS[boat.course][randi() % MISSPELLINGS[boat.course].size()]

	morse_encoder.message = get_boat_message()
	morse_encoder.start_encoding()

func get_boat_message():
	if boat.is_legit:
		return MAP[boat.course]
	else:
		return boat.mispelling

func _confirm_input_message(input: String) -> void:
	print("Game received input: ", input)
	if input.to_upper() == boat.course:
		score += 1
		score_label.text = "Score: " + str(score)
		print("Correct input! Score: ", score)
	else:
		print("Incorrect input. Expected: ", boat.course, ", but got: ", input)
	
	morse_receiver.reset_input()
	get_new_boat()
