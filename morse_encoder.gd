extends Node2D

const encoding_lengths = {
	"BETWEEN_LETTERS": 3,
	"BETWEEN_WORDS": 7
}

@export var message: String = "hello"

@onready var bulb: Label = $Bulb
@onready var clk: Timer = $Clock

var cycle_counter: int

var wave_fn = []

func _ready():
	bulb.text = "WAIT"

func start_encoding():
	cycle_counter = 0
	bulb.text = "🖤"

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

func _on_clock_timeout() -> void:
	bulb.text = "💛" if wave_fn[cycle_counter] else "🖤"
	cycle_counter += 1
	if cycle_counter == wave_fn.size() - 1:
		cycle_counter = 0
