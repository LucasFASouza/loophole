extends Node3D

const DIRECTIONS = ["N", "E", "S", "W"]

const MAP = {
	"N": "COAST",
	"E": "PORT",
	"S": "LIGHT",
	"W": "RIVER"
}

const MISSPELLINGS = {
	"N": ["COST", "COSTA", "COATS", "KRAKEN"],
	"E": ["PART", "POST", "PORK", "STORM"],
	"S": ["EIGHT ", "LITE", "RIGHT", "HELP"],
	"W": ["RIDER", "RISER", "RIGHT", "PLEASE"]
}

var boat = {
	"course": "",
	"is_legit": 1,
	"mispelling": "",
}

var chance_legitimacy := 66 # Chance of the boat being legitimate (0-100)

@onready var morse_antenna: Node3D = $MorseAntenna
@onready var morse_input: Node3D = $MorseInput
@onready var info_screen: Node3D = $InfoScreen

@onready var main_ui: MarginContainer = $CanvasLayer/MainUI
@onready var options_menu: PanelContainer = $CanvasLayer/OptionsMenu

var score := 0 


func _ready() -> void:
	get_new_boat()
	options_menu.visible = false
	main_ui.visible = true


func get_new_boat() -> void:
	"""
	Creates a new boat with a random course and legitimacy.
	"""
	boat = {
		"course": DIRECTIONS[randi() % DIRECTIONS.size()],
		"is_legit": randi() % 100 < chance_legitimacy,
		"mispelling": ""
	}

	if not boat.is_legit:
		boat.mispelling = MISSPELLINGS[boat.course][randi() % MISSPELLINGS[boat.course].size()]
	
	morse_input.reset_input()
	morse_antenna.message = get_boat_message()
	morse_antenna.start_encoding()


func get_boat_message():
	if boat.is_legit:
		return MAP[boat.course]
	else:
		return boat.mispelling


func _confirm_input_message(input: String) -> void:
	var status: String

	print("\nConfirming input: ", input)
	print("Boat course: ", boat.course)
	print("Boat message: ", get_boat_message())
	print("Boat legitimacy: ", boat.is_legit)

	var correct_direction: bool = input.to_upper().replace("?", "") == boat.course

	if boat.is_legit:
		if correct_direction:
			status = "Correct!"
			score += 1
		else:
			status = "Boat lost :("
			score -= 1
	else:
		if input.to_upper() == "O":
			status = "Pirate avoided!"
			score += 1
		elif correct_direction:
			status = "Pirates fleed :("
			score -= 1
	
	info_screen.update_score(score)
	info_screen.show_status(status)
	get_new_boat()


func _on_pause_pressed() -> void:
	options_menu.visible = true
	main_ui.visible = false
	get_tree().paused = true


func _on_options_menu_close_options() -> void:
	options_menu.visible = false
	main_ui.visible = true
	get_tree().paused = false
	
