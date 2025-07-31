extends Node3D

const encoding_lengths = {
	"BETWEEN_LETTERS": 3,
	"BETWEEN_WORDS": 7
}

@export var message: String = "hello"

@onready var clk: Timer = $Clock
@onready var wait_timer: Timer = $WaitTimer

@onready var antena_light: Node3D = $Antena/Light
@onready var beep_player: AudioStreamPlayer = $BeepPlayer

var cycle_counter: int

var wave_fn = []

func _ready():
	antena_light.visible = false
	beep_player.stop()
	clk.wait_time = MorseTranslator.CLK_TIME
	wait_timer.wait_time = MorseTranslator.CLK_TIME * 10

func start_encoding():
	wait_timer.start()

func _on_clock_timeout() -> void:
	var wave_on = wave_fn[cycle_counter]
	antena_light.visible = wave_on
	
	if not wave_on:
		beep_player.stop()
	elif not beep_player.playing:
		beep_player.play()
		
	cycle_counter += 1
	if cycle_counter == wave_fn.size() - 1:
		cycle_counter = 0


func _on_wait_timer_timeout() -> void:
	cycle_counter = 0
	antena_light.visible = false
	beep_player.stop()

	var morse_message = MorseTranslator.ascii_to_morse(message)

	const char_lengths = {
		'.': [1],
		'-': [1, 1, 1],
		'/': [0, 0, 0]
	}

	wave_fn = []
	
	for ch in morse_message:
		wave_fn.append_array(char_lengths[ch])
		wave_fn.append(0)

	wave_fn.append_array([0, 0, 0, 0, 0, 0, 0, 0, 0, 0])

	clk.start()
