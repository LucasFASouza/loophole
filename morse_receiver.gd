extends Node3D

const TIME_DASH := 0.9
const RESET_TIMER := 3.0

@onready var label_writting: Label3D = %LabelWritting
@onready var label_meaning: Label3D = %LabelMeaning
@onready var label_score: Label3D = %LabelScore
@onready var label_status: Label3D = %LabelStatus

@onready var dash_timer: Timer = $DashTimer
@onready var reset_timer: Timer = $ResetTimer
@onready var status_timer: Timer = $StatusTimer

var morse_text:= ""
var ascii_text:= ""

signal confirm_pressed(input: String)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("morse_input"):
		morse_text += "."
		dash_timer.start(TIME_DASH)
		update_morse_labels()
		reset_timer.stop()
	
	if Input.is_action_just_released("morse_input"):
		dash_timer.stop()
		update_morse_labels()
		reset_timer.start(RESET_TIMER)
		
	if Input.is_action_just_pressed("morse_cancel"):
		reset_input()
	if Input.is_action_just_pressed("morse_confirm"):
		confirm_pressed.emit(ascii_text)

func _on_dash_timeout() -> void:
	if morse_text.length() > 0:
		morse_text = morse_text.substr(0, morse_text.length() - 1) + "-"
		update_morse_labels()

func update_morse_labels() -> void:
	label_writting.text = morse_text
	ascii_text = ""

	if morse_text.length() > 0:
		ascii_text = MorseTranslator.morse_to_ascii(morse_text)

	label_meaning.text = ascii_text

func _on_reset_timer_timeout() -> void:
	reset_input()

func reset_input() -> void:
	"""
	Resets the input fields.
	"""
	morse_text = ""
	ascii_text = ""
	update_morse_labels()
	dash_timer.stop()
	reset_timer.stop()

func finish_round(score: int, reason: String) -> void:
	label_score.text = "Score: " + str(score)
	label_status.text = reason
	label_status.visible = true
	status_timer.start(2)
	
	reset_input()


func _on_status_timer_timeout() -> void:
	label_status.visible = false
