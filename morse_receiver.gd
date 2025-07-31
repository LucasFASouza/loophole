extends Node2D

const TIME_DASH := 0.9
const RESET_TIMER := 5.0

@onready var writting: Label = %Writting
@onready var meaning: Label = %Meaning
@onready var dash_timer: Timer = $DashTimer
@onready var reset_timer: Timer = $ResetTimer

var input_text:= ""

signal confirm_pressed(input: String)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("morse_input"):
		writting.text += "."
		dash_timer.start(TIME_DASH)
		reset_timer.stop()
	
	if Input.is_action_just_released("morse_input"):
		dash_timer.stop()
		_verify_morse_code()
		reset_timer.start(RESET_TIMER)
		
	if Input.is_action_just_pressed("morse_cancel"):
		reset_input()
	if Input.is_action_just_pressed("morse_confirm"):
		confirm_pressed.emit(input_text)

func _on_dash_timeout() -> void:
	if writting.text.length() > 0:
		writting.text = writting.text.substr(0, writting.text.length() - 1) + "-"
		_verify_morse_code()

func _verify_morse_code() -> void:
	if writting.text.length() > 0:
		input_text = MorseTranslator.morse_to_ascii(writting.text)
		meaning.text = input_text
	
func _on_reset_timer_timeout() -> void:
	reset_input()

func reset_input() -> void:
	"""
	Resets the input fields.
	"""
	writting.text = ""
	meaning.text = ""
	input_text = ""
	dash_timer.stop()
	reset_timer.stop()
