extends Node3D

@export var message: String = "hello"

@onready var clk: Timer = $Clock

@onready var antena_signal_light: MeshInstance3D = $Antena/Light
@onready var antena_reset_light: MeshInstance3D = $Antena/ResetLight

@onready var wave_sfx: AudioStreamPlayer = $BeepSFX

var cycle_counter: int

var sound_wave_fn = []
var light_wave_fn = []


func _ready():
	antena_signal_light.visible = false
	antena_reset_light.visible = false
	wave_sfx.stop()
	clk.wait_time = MorseTranslator.CLK_TIME


func stop_encoding() -> void:
	message = ""
	cycle_counter = 0
	sound_wave_fn = []
	light_wave_fn = []
	antena_signal_light.visible = false
	antena_reset_light.visible = false
	wave_sfx.stop()
	clk.stop()


func start_encoding(new_message: String) -> void:
	message = new_message

	var morse_message = MorseTranslator.ascii_to_morse(message)

	const char_sound_lengths = {
		'.': [1],
		'-': [2, 2, 2],
		'/': [0, 0, 0]
	}

	const char_light_lengths = {
		'.': [1],
		'-': [1, 1, 1],
		'/': [0, 0, 0]
	}
	
	for ch in morse_message:
		sound_wave_fn.append_array(char_sound_lengths[ch])
		light_wave_fn.append_array(char_light_lengths[ch])

		sound_wave_fn.append(0)
		light_wave_fn.append(0)
		

	sound_wave_fn.append_array([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
	light_wave_fn.append_array([0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 2, 0, 0, 0])

	clk.start()


func _on_clock_timeout() -> void:
	var light_mode = light_wave_fn[cycle_counter]

	antena_signal_light.visible = light_mode == 1
	antena_reset_light.visible = light_mode == 2

	var is_wave_fn_high = sound_wave_fn[cycle_counter]
	if (is_wave_fn_high && !wave_sfx.playing):
		if is_wave_fn_high == 1:
			wave_sfx.pitch_scale = 1.0
		if is_wave_fn_high == 2:
			wave_sfx.pitch_scale = 0.985

		wave_sfx.play()
	
	if not is_wave_fn_high:
		wave_sfx.stop()

	cycle_counter += 1
	if cycle_counter == sound_wave_fn.size() - 1:
		cycle_counter = 0
