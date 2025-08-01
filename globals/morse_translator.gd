extends Node

const CLK_TIME = 0.3

const MORSE_TO_ASCII_DICT = {
  ".-": "a",
  "-...": "b",
  "-.-.": "c",
  "-..": "d",
  ".": "e",
  "..-.": "f",
  "--.": "g",
  "....": "h",
  "..": "i",
  ".---": "j",
  "-.-": "k",
  ".-..": "l",
  "--": "m",
  "-.": "n",
  "---": "o",
  ".--.": "p",
  "--.-": "q",
  ".-.": "r",
  "...": "s",
  "-": "t",
  "..-": "u",
  "...-": "v",
  ".--": "w",
  "-..-": "x",
  "-.--": "y",
  "--..": "z"
}

const ASCII_TO_MORSE_DICT = {
  "A": ".-",
  "B": "-...",
  "C": "-.-.",
  "D": "-..",
  "E": ".",
  "F": "..-.",
  "G": "--.",
  "H": "....",
  "I": "..",
  "J": ".---",
  "K": "-.-",
  "L": ".-..",
  "M": "--",
  "N": "-.",
  "O": "---",
  "P": ".--.",
  "Q": "--.-",
  "R": ".-.",
  "S": "...",
  "T": "-",
  "U": "..-",
  "V": "...-",
  "W": ".--",
  "X": "-..-",
  "Y": "-.--",
  "Z": "--.."
}

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
			if MORSE_TO_ASCII_DICT.has(letter):
				ascii_word += MORSE_TO_ASCII_DICT[letter]
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
		if ASCII_TO_MORSE_DICT.has(charac):
			result.append(ASCII_TO_MORSE_DICT[charac])
		else:
			result.append("?")
	return "/".join(result).strip_edges()
