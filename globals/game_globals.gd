extends Node


var volumes = {
	"Master": 0.5,
	"SFX": 0.5,
	"Music": 0.5
}

var GAME_MODE: String = "nights" # normal, endless


func set_bus_volume(bus_name: String, value: float) -> void:
	var bus_idx = AudioServer.get_bus_index(bus_name)

	var volume_db = -80.0 if value <= 0.0 else linear_to_db(value)
	AudioServer.set_bus_volume_db(bus_idx, volume_db)

	volumes[bus_name] = value
