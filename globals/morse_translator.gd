extends Node

const CLK_TIME = 0.3

var morse_to_ascii_dict: Dictionary = {}
var ascii_to_morse_dict: Dictionary = {}

func _ready() -> void:
	_read_morse_dict()

func _read_morse_dict() -> void:
	"""
	Populates both dictionaries from a JSON file.
	"""
	var file = FileAccess.open("res://data/morse.json", FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		var result = JSON.parse_string(json_text)
		if typeof(result) == TYPE_DICTIONARY:
			morse_to_ascii_dict = result

			ascii_to_morse_dict.clear()
			for morse in morse_to_ascii_dict.keys():
				var letter = morse_to_ascii_dict[morse].to_upper()
				ascii_to_morse_dict[letter] = morse
		file.close()

func morse_to_ascii(morse_text: String) -> String:
	"""
	Converts a Morse code string to ascii.
	example: ".../---/..." -> "SOS"
	"""
	var words = morse_text.strip_edges().split("/")
	var result = []
	for word in words:
		var letters = word.split(" ")
		var ascii_word = ""
		for letter in letters:
			if morse_to_ascii_dict.has(letter):
				ascii_word += morse_to_ascii_dict[letter]
			else:
				ascii_word += "?"

		result.append(ascii_word)

	return "".join(result).strip_edges()

func ascii_to_morse(ascii_text: String) -> String:
	"""
	Converts an ascii string to Morse code.
	example: "SOS" -> "... / --- / ..."
	"""
	var result = []
	for charac in ascii_text.to_upper():
		if ascii_to_morse_dict.has(charac):
			result.append(ascii_to_morse_dict[charac])
		else:
			result.append("?")
	return "/".join(result).strip_edges()
