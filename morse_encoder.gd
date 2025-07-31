extends Node

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
	print("morse wave fn: ", wave_fn)
	clk.start()


func _on_clock_timeout() -> void:
	bulb.text = "💛" if wave_fn[cycle_counter] else "🖤"
	print("on")
	cycle_counter += 1
	if cycle_counter == wave_fn.size() - 1:
		cycle_counter = 0
