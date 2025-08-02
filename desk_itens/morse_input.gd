extends Node3D

@onready var label_writing: Label3D = %LabelWriting
@onready var label_meaning: Label3D = %LabelMeaning

@onready var dash_timer: Timer = $DashTimer
@onready var word_timer: Timer = $WordTimer

var is_ready: bool = false

var morse_text:= ""
var ascii_text:= ""

signal check_word(input: String)


func _process(_delta: float) -> void:
	if not is_ready:
		return

	if Input.is_action_just_pressed("morse_input"):
		morse_text += "."
		dash_timer.start(MorseTranslator.CLK_TIME * 2)
		update_morse_labels()
		word_timer.stop()
	
	if Input.is_action_just_released("morse_input") and morse_text.length() > 0:
		dash_timer.stop()
		update_morse_labels()
		word_timer.start(MorseTranslator.CLK_TIME * 2.5)
		
	if Input.is_action_just_pressed("morse_confirm"):
		check_word.emit(ascii_text)
		word_timer.stop()
		
	if Input.is_action_just_pressed("morse_delete"):
		morse_text = morse_text.substr(0, morse_text.length() - 1)
		word_timer.start(MorseTranslator.CLK_TIME * 2.5)
		update_morse_labels()


func update_morse_labels() -> void:
	label_writing.text = morse_text
	ascii_text = ""

	if morse_text.length() > 0:
		ascii_text = MorseTranslator.morse_to_ascii(morse_text)

	label_meaning.text = ascii_text


func reset_input() -> void:
	"""
	Resets the input fields.
	"""
	morse_text = ""
	ascii_text = ""
	update_morse_labels()
	dash_timer.stop()
	word_timer.stop()


func _on_dash_timeout() -> void:
	if morse_text.length() > 0:
		morse_text = morse_text.substr(0, morse_text.length() - 1) + "-"
		update_morse_labels()


func _on_word_timer_timeout() -> void:
	morse_text += "/"
	update_morse_labels()
