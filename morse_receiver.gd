extends Node

const TIME_DASH := 0.5

# Morse code dictionary loaded from JSON
var morse_dict: Array = []

@onready var writting: Label = %Writting
@onready var meaning: Label = %Meaning
@onready var dash_timer: Timer = $DashTimer

func _ready() -> void:
	dash_timer.timeout.connect(_on_dash_timeout)
	var file = FileAccess.open("res://morse.json", FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		var result = JSON.parse_string(json_text)
		if typeof(result) == TYPE_ARRAY:
			morse_dict = result
		file.close()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		writting.text += "."
		dash_timer.start(TIME_DASH)
	
	if Input.is_action_just_released("ui_accept"):
		dash_timer.stop()
		var found = false
		for entry in morse_dict:
			if entry.has("input") and entry["input"] == writting.text:
				meaning.text = entry["meaning"]
				found = true
				break
		if not found:
			meaning.text = ""

func _on_dash_timeout() -> void:
	if writting.text.length() > 0:
		writting.text = writting.text.substr(0, writting.text.length() - 1) + "-"
