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

var wave_fn = []

func _ready():
	antena_light.visible = false
	dash_sfx.stop()
	dot_sfx.stop()
	clk.wait_time = MorseTranslator.CLK_TIME


func stop_encoding() -> void:
	message = ""
	cycle_counter = 0
	wave_fn = []
	antena_light.visible = false
	dash_sfx.stop()
	dot_sfx.stop()
	clk.stop()


func start_encoding(new_message: String) -> void:
	message = new_message

	var morse_message = MorseTranslator.ascii_to_morse(message)

	const char_lengths = {
		'.': [1],
		'-': [2, 2, 2],
		'/': [0, 0, 0]
	}
	
	for ch in morse_message:
		wave_fn.append_array(char_lengths[ch])
		wave_fn.append(0)

	wave_fn.append_array([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])

	clk.start()


func _on_clock_timeout() -> void:
	var wave_on = wave_fn[cycle_counter]
	antena_light.visible = wave_on
	

	if wave_on == 1:
		dot_sfx.play()
	if wave_on == 2 and not dash_sfx.playing:
		dash_sfx.play()
		
	cycle_counter += 1
	if cycle_counter == wave_fn.size() - 1:
		cycle_counter = 0


func _on_wait_timer_timeout() -> void:
	var morse_message = MorseTranslator.ascii_to_morse(message)
	print(message)
	print(morse_message)

	const char_lengths = {
		'.': [1],
		'-': [2, 2, 2],
		'/': [0, 0, 0]
	}
