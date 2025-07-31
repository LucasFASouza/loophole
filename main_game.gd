extends Node3D

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

@onready var morse_receiver: Node3D = $MorseReceiver
@onready var morse_encoder: Node3D = $MorseEncoder

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
	var status: String
	if input.to_upper() == boat.course:
		score += 1
		status = "Correct!"
	else:
		status = "Incorrect :("
	
	morse_receiver.finish_round(score, status)
	get_new_boat()
