extends PanelContainer

@onready var master_volume_slider: HSlider = %MasterVolumeSlider
@onready var sfx_slider: HSlider = %SfxSlider
@onready var music_slider: HSlider = %MusicSlider

signal close_options

func _ready() -> void:
	await get_tree().process_frame 

	master_volume_slider.value = GameGlobals.volumes["Master"]
	sfx_slider.value = GameGlobals.volumes["SFX"]
	music_slider.value = GameGlobals.volumes["Music"]


func _on_master_volume_changed(value: float) -> void:
	GameGlobals.set_bus_volume("Master", value)


func _on_sfx_value_changed(value: float) -> void:
	GameGlobals.set_bus_volume("SFX", value)


func _on_music_value_changed(value: float) -> void:
	GameGlobals.set_bus_volume("Music", value)


func _on_back_pressed() -> void:
	close_options.emit()


func _on_main_menu_pressed() -> void:
	close_options.emit()
	get_tree().change_scene_to_file("res://core/main_menu.tscn")
