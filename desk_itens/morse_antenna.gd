extends Node3D

const encoding_lengths = {
	"BETWEEN_LETTERS": 3,
	"BETWEEN_WORDS": 7
}

@export var message: String = "hello"

@onready var clk: Timer = $Clock

@onready var antena_light: Node3D = $Antena/Light
@onready var dot_sfx: AudioStreamPlayer = $DotSFX
@onready var dash_sfx: AudioStreamPlayer = $DashSFX

var cycle_counter: int

var sound_wave_fn = []
var light_wave_fn = []


func _ready():
	antena_light.visible = false
	dash_sfx.stop()
	dot_sfx.stop()
	clk.wait_time = MorseTranslator.CLK_TIME


func stop_encoding() -> void:
	message = ""
	cycle_counter = 0
	sound_wave_fn = []
	light_wave_fn = []
	antena_light.visible = false
	dash_sfx.stop()
	dot_sfx.stop()
	clk.stop()


func start_encoding(new_message: String) -> void:
	message = new_message

	var morse_message = MorseTranslator.ascii_to_morse(message)

	const char_sound_lengths = {
		'.': [1],
		'-': [2, 0, 0],
		'/': [0, 0, 0]
	}

	const char_light_lengths = {
		'.': [1],
		'-': [2, 2, 2],
		'/': [0, 0, 0]
	}
	
	for ch in morse_message:
		sound_wave_fn.append_array(char_sound_lengths[ch])
		light_wave_fn.append_array(char_light_lengths[ch])
		
		sound_wave_fn.append(0)
		light_wave_fn.append(0)
		

	sound_wave_fn.append_array([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
	light_wave_fn.append_array([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])

	clk.start()


func _on_clock_timeout() -> void:
	var sound_wave_on = sound_wave_fn[cycle_counter]
	antena_light.visible = light_wave_fn[cycle_counter]

	if sound_wave_on == 1:
		dot_sfx.play()
	if sound_wave_on == 2 and not dash_sfx.playing:
		dash_sfx.play()
		
	cycle_counter += 1
	if cycle_counter == sound_wave_fn.size() - 1:
		cycle_counter = 0
