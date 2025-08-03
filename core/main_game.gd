extends Node3D

@onready var morse_antenna: Node3D = $MorseAntenna
@onready var morse_input: Node3D = $MorseInput
@onready var info_screen: Node3D = $InfoScreen

@onready var book: Node3D = $Book
@onready var gps: Node3D = $GPS
@onready var walkie_talkie: Node3D = $WalkieTalkie

@onready var finish_container: PanelContainer = %FinishContainer

@onready var night_title: Label = %NightTitle
@onready var next_img_button: Button = %NextImgButton
@onready var prev_img_button: Button = %PrevImgButton
@onready var tutorial_img: VBoxContainer = %TutorialImgContainer
@onready var tutorial_container: PanelContainer = %TutorialContainer
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

@onready var calendar: Node3D = $Calendar
@onready var erase_board: Node3D = $EraseBoard
@onready var lighthouse: Node3D = $Lighthouse

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

var boat = {}

var nights_data = [
	{
		"name": "Night 0",
		"mission": "Calibrate the system by reproducing and confirming the transmission loops",
		"task": "CONFIRM TRANSMISSIONS",
		"task_threshold": 3,
	},
	{
		"name": "Night 1",
		"mission": "Use your GPS system to relay the destination coordinates to the boats",
		"task": "SEND COORDINATES",
		"task_threshold": 3,
	},
	{
		"name": "Night 2",
		"mission": "Use your radio system to relay the incoming alerts to the authorities",
		"task": "ALERT AUTHORITIES",
		"task_threshold": 3,
	},
	{
		"name": "Night 3",
		"mission": "Make full use of your station’s systems to relay the boats’ messages and help them navigate",
		"task": "RESPOND TO SIGNALS",
		"task_threshold": 4,
	}
]

var score = 0
var night := -1
var helped_boats := 0
var lost_boats = 0
var is_nights_mode := GameGlobals.GAME_MODE == "nights"

var current_tutorial_img = 0;
var night_tutorial_img: Array[Texture2D] = []
var tutorial_image_counts = [4, 5, 5, 3]

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


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_book") and boat:
		book.item_info.visible = not book.item_info.visible


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
	
	lighthouse.get_node("Lamp").visible = boat.message != "DARK"

	wait_timer.start()
	

func check_word(input: String) -> void:
	var status: String

	if input == boat.message:
		status = "Message confirmed!"

		if boat.type == "Calibration" and boat.answer == input:
			score += 1
			GameGlobals.play_sfx(GameGlobals.GlobalSoundEffect.CORRECT_ANSWER)
			info_screen.update_score(str(score + 2) + " letters", 0, nights_data[night]["task"])

			if score >= nights_data[night]["task_threshold"]:
				finish_night()
			else:
				get_new_boat()

	elif boat.message.findn(input) == 0:
		status = "That part checks out..."
	else:
		status = "Incorrect message :/"
		GameGlobals.play_sfx(GameGlobals.GlobalSoundEffect.INCORRECT_ANSWER)
	
	info_screen.show_status(status)


func _send_answer(input: String) -> void:
	if not input or not wait_timer.is_stopped():
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


func load_night_tutorial(night_number: int) -> void:
	var night_index = int(night_number)
	if night_index < 0 or night_index >= nights_data.size():
		night_index = nights_data.size() - 1

	current_tutorial_img = 0

	if is_nights_mode:
		night_title.text = nights_data[night_index]["name"]
	else:
		night_title.text = "Endless Mode"

	night_tutorial_img = []
	for n in range(tutorial_image_counts[night_index]):
		var img_path = "res://assets/tutorial/night{night}_tutorial{idx}.jpg"
		var texture = load(
			img_path.format({"night": night_index, "idx": n + 1})
		) as Texture2D
		night_tutorial_img.append(texture)
	
	tutorial_container.visible = true
	next_img_button.grab_focus()
	main_ui.visible = false
		
	%TutorialImgContainer/TutorialImg.texture = night_tutorial_img[current_tutorial_img]
	next_img_button.text = "NEXT >"
	prev_img_button.disabled = true
		

func prepare_night() -> void:
	night_name.text = nights_data[night]["name"]
	erase_board.get_node("Instructions").text = nights_data[night]["mission"]

	score = 0
	info_screen.update_score(score, nights_data[night]["task_threshold"], nights_data[night]["task"])

	if night == 0:
		info_screen.update_score(str(score + 2) + " letters", 0, nights_data[night]["task"])
		calendar.get_node("Night0").visible = true
	elif night == 1:
		gps.visible = true
		calendar.get_node("Night1").visible = true
	elif night == 2:
		walkie_talkie.visible = true
		calendar.get_node("Night2").visible = true
	elif night == 3:
		calendar.get_node("Night3").visible = true

	load_night_tutorial(night)


func prepare_endless_mode() -> void:
	for night_number in range(nights_data.size()):
		book.unlock_page(night_number)

	gps.visible = true
	walkie_talkie.visible = true

	calendar.get_node("Night0").visible = true
	calendar.get_node("Night1").visible = true
	calendar.get_node("Night2").visible = true
	calendar.get_node("Night3").visible = true
	calendar.get_node("Endless").visible = true
	
	night_title.text = "Endless Mode"
	night_name.text = "60s"
	erase_board.get_node("Instructions").text = nights_data[night]["mission"]
	
	endless_timer.wait_time = 60.0

	score = 0
	info_screen.update_score(score, 0, nights_data[night]["task"])

	load_night_tutorial(night)


func finish_night() -> void:
	boat = {}
	morse_antenna.stop_encoding()
	morse_input.reset_input()
	morse_input.is_ready = false

	night += 1

	if night >= nights_data.size():
		finish_game()
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
	var night_index = int(night)
	if night == -1:
		night_index = int(nights_data.size() - 1)
		
	if current_tutorial_img < tutorial_image_counts[night_index] - 1:
		current_tutorial_img += 1
		%TutorialImgContainer/TutorialImg.texture = night_tutorial_img[current_tutorial_img]
		if current_tutorial_img == tutorial_image_counts[night_index] - 1:
			next_img_button.text = "START"
		elif current_tutorial_img > 0:
			prev_img_button.disabled = false
		return
	
	morse_input.is_ready = true

	if not is_nights_mode:
		endless_timer.start()

	get_new_boat()
	tutorial_container.visible = false
	main_ui.visible = true


func _on_back_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://core/main_menu.tscn")


func _on_endless_timer_timeout() -> void:
	finish_game()


func finish_game() -> void:
	morse_antenna.stop_encoding()
	morse_input.reset_input()
	morse_input.is_ready = false
	main_ui.visible = false

	var night_counters_text = "You answered " + str(helped_boats) + " successful relays.\n"
	var final_text = ""
	
	if is_nights_mode:
		night_counters_text += "And made " + str(lost_boats) + " mistakes."

		final_text = "Mission accomplished — for now.\nAlso try the endless mode!"
	else:
		night_counters_text += "And had " + str(lost_boats) + " unresolved transmissions."

		if lost_boats > helped_boats:
			final_text = "You made more boats sink than you saved...\nBetter luck next time!"
		elif helped_boats > 5:
			final_text = "Great job! The sea is safer thanks to you!"
		elif helped_boats > 2:
			final_text = "Very good! Keep it up!"
		elif helped_boats <= 2:
			final_text = "You can do better! Keep practicing."

	night_counters.text = night_counters_text
	play_endless.text = final_text
	finish_container.visible = true


func _on_play_again_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_show_controls_pressed() -> void:
	show_controls.visible = false
	buttons_tips.visible = true


func _on_hide_controls_pressed() -> void:
	show_controls.visible = true
	buttons_tips.visible = false


func _on_prev_img_button_pressed() -> void:
	if current_tutorial_img > 0:
		current_tutorial_img -= 1
		%TutorialImgContainer/TutorialImg.texture = night_tutorial_img[current_tutorial_img]
		if current_tutorial_img < tutorial_image_counts[night] - 1:
			next_img_button.text = "NEXT >"

		prev_img_button.disabled = current_tutorial_img == 0
