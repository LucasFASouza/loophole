extends Node

const TIME_DASH := 0.5
const TIME_WORD := 1.0

@onready var writting: Label = %Writting
@onready var meaning: Label = %Meaning
@onready var word_timer: Timer = $WordTimer
var _pressed_time: int = 0

var _is_holding := false
var _last_dot_index := -1


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		_pressed_time = Time.get_ticks_msec()
		writting.text += "."
		_is_holding = true
		_last_dot_index = writting.text.length() - 1
		if word_timer.is_stopped() == false:
			word_timer.stop()

	if _is_holding:
		var duration = (Time.get_ticks_msec() - _pressed_time) / 1000.0
		if duration > TIME_DASH and _last_dot_index >= 0 and writting.text[_last_dot_index] == ".":
			writting.text = writting.text.substr(0, _last_dot_index) + "-" + writting.text.substr(_last_dot_index + 1)

	if Input.is_action_just_released("ui_accept"):
		_is_holding = false
		_last_dot_index = -1
		word_timer.start(TIME_WORD)

# Called when word_timer times out
func _on_word_timer_timeout():
	writting.text += "/"
