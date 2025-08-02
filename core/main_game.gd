extends Node3D

@onready var morse_antenna: Node3D = $MorseAntenna
@onready var morse_input: Node3D = $MorseInput
@onready var info_screen: Node3D = $InfoScreen

@onready var book: Node3D = $Book
@onready var gps: Node3D = $GPS
@onready var walkie_talkie: Node3D = $WalkieTalkie

@onready var start_container: PanelContainer = %StartContainer
@onready var night_title: Label = %NightTitle
@onready var night_instructions: Label = %NightInstructions
@onready var start_night_button: Button = %StartNightButton

@onready var finish_container: PanelContainer = %FinishContainer
@onready var night_counters: Label = %NightCounters
@onready var play_endless: Label = %PlayEndless

@onready var wait_timer: Timer = $WaitTimer
@onready var endless_timer: Timer = $EndlessTimer

@onready var main_ui: MarginContainer = $CanvasLayer/MainUI
@onready var options_menu: PanelContainer = $CanvasLayer/OptionsMenu

@onready var night_name: Label = %NightNumber
@onready var mission_text: Label = %MissionText

@onready var show_controls: Button = %ShowControls
@onready var buttons_tips: Control = %ButtonsTips

var calibration_words = [
	["UP", "WE", "OK"],
	["SOS", "MAP", "JAM"],
	["GAME", "FISH", "LOOP"]
]

var coordinates = {
	"1A": "KELP",
	"2B": "PORT",
	"2D": "ISLE",
	"4B": "GATE",
}

var frequencies = {
	"157": "AHOY",
	"111": "DARK",
	"179": "GALE",
	"125": "KING"
}

var boat = {
	"message": "",
	"type": "", # Calibration, GPS, Radio
	"answer": "",
}

var nights_data = [
	{
		"name": "Night 0",
		"mission": "Calibrate the system by reproducing and confirming the transmission loops.\nCheck your book for more information.\n",
		"start_instructions": """Before you begin, you should calibrate your machinery.

			Listen carefully to the looped transmissions and try to reproduce the morse message to verify its content.

			Press or hold [SPACE] to send a signal.
			Wait for pauses between letters.
			Use [BACKSPACE] to delete characters.
			When you're confident with your answer, press [ENTER] to submit it.

			At any time, you may check your book for more notes and references.""",
		"task": "CONFIRM TRANSMISSIONS",
		"task_threshold": 3,
	},
	{
		"name": "Night 1",
		"mission": "Use your GPS system to relay the destination coordinates to the boats.\nCheck your book for the references.\n",
		"start_instructions": """Help the boats navigate by relaying their destination coordinates.

			Listen carefully to the looped transmission to identify the 4-letter destination code.
			Use your book to look up the corresponding coordinates. Then, transmit them using the GPS system.

			You may choose to verify the destination with the boat before sending — or trust your instincts with a half-solved message.""",
		"task": "SEND COORDINATES",
		"task_threshold": 3,
	},
	{
		"name": "Night 2",
		"mission": "Use your radio system to relay the incoming alerts to the authorities.\nCheck your book for the references.\n",
		"start_instructions": """Help the port stay safe by relaying incoming alerts to the proper authorities.

			Listen carefully to the looped transmission to identify the 4-letter alert code.
			Use your book to find the corresponding radio frequency. Then, transmit the message using your walkie-talkie.

			You may choose to double-check the alert’s meaning — or act quickly, trusting your first interpretation.""",
		"task": "ALERT AUTHORITIES",
		"task_threshold": 3,
	},
	{
		"name": "Night 3",
		"mission": "Make full use of your station’s systems to relay the boats’ messages and help them navigate.",
		"start_instructions": """Rely on all your tools to keep operations running smoothly.

			Listen carefully to the looped transmission to identify the 4-letter code.
			Some messages indicate destinations — others are urgent alerts. Each requires a different response.

			Use your book to determine the correct procedure. Trust your equipment, stay focused, and act fast when it matters most.""",
		"task": "RESPOND TO SIGNALS",
		"task_threshold": 4,
	}
]

var score = 0
var night := -1
var helped_boats := 0
var lost_boats = 0
var is_nights_mode := GameGlobals.GAME_MODE == "nights"

func _ready() -> void:
	wait_timer.wait_time = MorseTranslator.CLK_TIME * 8
	options_menu.visible = false
	main_ui.visible = true
	buttons_tips.visible = false
	
	finish_container.visible = false

	morse_antenna.stop_encoding()
	morse_input.is_ready = false
	morse_input.reset_input()

	gps.visible = false
	walkie_talkie.visible = false

	if is_nights_mode:
		night = 0
		prepare_night()
	else:
		prepare_endless_mode()


func _process(_delta: float) -> void:
	if not is_nights_mode and not endless_timer.is_stopped():
		var seconds_left = int(endless_timer.time_left)
		if seconds_left < 0:
			seconds_left = 0
		night_name.text = str(seconds_left) + "s"


func get_new_boat() -> void:
	"""
	Creates a new boat with a random course and legitimacy.
	"""
	morse_antenna.stop_encoding()
	morse_input.reset_input()

	match night:
		0:
			boat.type = "Calibration"
			boat.message = calibration_words[score][randi() % calibration_words[score].size()]
			boat.answer = boat.message

		1:
			boat.type = "GPS"

			var keys = coordinates.keys()
			boat.answer = keys[randi() % keys.size()]
			boat.message = coordinates[boat.answer]
		2:
			boat.type = "Radio"

			var keys = frequencies.keys()
			boat.answer = keys[randi() % keys.size()]
			boat.message = frequencies[boat.answer]
		_:
			# get a random boat type
			var boat_types = ["GPS", "Radio"]
			boat.type = boat_types[randi() % boat_types.size()]

			var boat_dict = {}

			if boat.type == "Radio":
				boat_dict = frequencies
			elif boat.type == "GPS":
				boat_dict = coordinates

			var keys = boat_dict.keys()
			boat.answer = keys[randi() % keys.size()]
			boat.message = boat_dict[boat.answer]

	wait_timer.start()
	

func check_word(input: String) -> void:
	var status: String

	if input == boat.message:
		status = "Message confirmed!"

		if boat.type == "Calibration" and boat.answer == input:
			score += 1
			GameGlobals.play_sfx(GameGlobals.GlobalSoundEffect.CORRECT_ANSWER)
			info_screen.update_score(score, nights_data[night]["task_threshold"], nights_data[night]["task"])

			mission_text.text = nights_data[night]["mission"] + "\nCurrent calibration: " + str(score + 2) + " letters"

			if score >= nights_data[night]["task_threshold"]:
				finish_night()
			else:
				get_new_boat()

	elif input in boat.message:
		status = "That part checks out..."
	else:
		status = "Incorrect message :/"
		GameGlobals.play_sfx(GameGlobals.GlobalSoundEffect.INCORRECT_ANSWER)
	
	info_screen.show_status(status)


func _send_answer(input: String) -> void:
	if not input:
		return

	var status: String

	var correct_direction: bool = input.to_upper().replace("?", "") == boat.answer
	if (correct_direction):
		GameGlobals.play_sfx(GameGlobals.GlobalSoundEffect.CORRECT_ANSWER)
	else:
		GameGlobals.play_sfx(GameGlobals.GlobalSoundEffect.INCORRECT_ANSWER)

	if correct_direction:
		status = "Successfull relay! :D"
		score += 1
		helped_boats += 1
	else:
		status = "Transmission failed :("
		lost_boats += 1

	if is_nights_mode:
		info_screen.update_score(score, nights_data[night]["task_threshold"], nights_data[night]["task"])
	else:
		info_screen.update_score(score, 0, nights_data[night]["task"])

		var time_added: int

		if correct_direction:
			time_added = max(30 - (3 * score), 0)
			status += "\n+" + str(time_added) + "s to the timer!"
		else:
			time_added = -10
			status += "\n-10s to the timer!"
			
		endless_timer.wait_time = endless_timer.time_left + time_added
		endless_timer.stop()
		endless_timer.start()

	info_screen.show_status(status)

	if score >= nights_data[night]["task_threshold"] and is_nights_mode:
		finish_night()
	else:
		get_new_boat()


func prepare_night() -> void:
	night_name.text = nights_data[night]["name"]
	mission_text.text = nights_data[night]["mission"]

	if night == 0:
		mission_text.text += "\nCurrent calibration: " + str(score + 2) + " letters"
	elif night == 1:
		gps.visible = true
	elif night == 2:
		walkie_talkie.visible = true

	night_title.text = nights_data[night]["name"]
	night_instructions.text = nights_data[night]["start_instructions"]
	
	score = 0
	info_screen.update_score(score, nights_data[night]["task_threshold"], nights_data[night]["task"])

	start_container.visible = true
	start_night_button.grab_focus()
	main_ui.visible = false


func prepare_endless_mode() -> void:
	for night_number in range(nights_data.size()):
		book.unlock_page(night_number)

	gps.visible = true
	walkie_talkie.visible = true
	
	night_title.text = "Endless Mode"
	night_name.text = "60s"
	night_instructions.text = nights_data[night]["start_instructions"]
	mission_text.text = nights_data[night]["mission"]
	
	endless_timer.wait_time = 60.0

	score = 0
	info_screen.update_score(score, 0, nights_data[night]["task"])

	start_container.visible = true
	start_night_button.grab_focus()
	main_ui.visible = false


func finish_night() -> void:
	morse_antenna.stop_encoding()
	morse_input.reset_input()
	morse_input.is_ready = false

	night += 1

	if night >= nights_data.size():
		main_ui.visible = false
		var night_counters_text = "You answered " + str(helped_boats) + " successful relays.\nAnd had " + str(lost_boats) + " unresolved transmissions."
		night_counters.text = night_counters_text
		finish_container.visible = true
	else:
		book.unlock_page(night)
		prepare_night()


func _on_pause_pressed() -> void:
	options_menu.visible = true
	main_ui.visible = false
	get_tree().paused = true


func _on_options_menu_close_options() -> void:
	options_menu.visible = false
	main_ui.visible = true
	get_tree().paused = false


func _on_wait_timer_timeout() -> void:
	info_screen.show_status("INCOMING TRANSMISSION")
	morse_antenna.start_encoding(boat.message)


func _on_start_night_button_pressed() -> void:
	morse_input.is_ready = true

	if not is_nights_mode:
		endless_timer.start()

	get_new_boat()
	start_container.visible = false
	main_ui.visible = true


func _on_back_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://core/main_menu.tscn")


func _on_endless_timer_timeout() -> void:
	morse_antenna.stop_encoding()
	morse_input.reset_input()
	morse_input.is_ready = false

	main_ui.visible = false
	var night_counters_text = "You answered " + str(helped_boats) + " successful relays.\nAnd had " + str(lost_boats) + " unresolved transmissions."
	night_counters.text = night_counters_text
	finish_container.visible = true

	var final_text = ""
	
	if is_nights_mode:
		final_text = "Mission accomplished — for now.\nAlso try the endless mode!"
	else:
		if lost_boats > helped_boats:
			final_text = "You made more boats sink than you saved...\nBetter luck next time!"
		elif helped_boats > 5:
			final_text = "Great job! The sea is safer thanks to you!"
		elif helped_boats > 2:
			final_text = "Very good! Keep it up!"
		elif helped_boats <= 2:
			final_text = "You can do better! Keep practicing."

	play_endless.text = final_text

func _on_play_again_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_show_controls_pressed() -> void:
	show_controls.visible = false
	buttons_tips.visible = true


func _on_hide_controls_pressed() -> void:
	show_controls.visible = true
	buttons_tips.visible = false
