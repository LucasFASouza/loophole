extends Node

const TIME_DASH := 0.5

@onready var writting: Label = %Writting
@onready var meaning: Label = %Meaning
@onready var dash_timer: Timer = $DashTimer

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		writting.text += "."
		dash_timer.start(TIME_DASH)
	
	if Input.is_action_just_released("ui_accept"):
		dash_timer.stop()
		_verify_morse_code()

func _on_dash_timeout() -> void:
	if writting.text.length() > 0:
		writting.text = writting.text.substr(0, writting.text.length() - 1) + "-"
		_verify_morse_code()

func _verify_morse_code() -> void:
	if writting.text.length() > 0:
		meaning.text = MorseTranslator.morse_to_ascii(writting.text)
	
