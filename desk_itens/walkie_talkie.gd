extends Node3D

@onready var frequency_label: Label = %FrequencyLabel
@onready var frequency_slider: HScrollBar = %FrequencySlider
@onready var item_info: CanvasLayer = $ItemInfo
@onready var sine_sfx: AudioStreamPlayer = GameGlobals.soundEffects[GameGlobals.GlobalSoundEffect.SINE]
@onready var noise_sfx: AudioStreamPlayer = GameGlobals.soundEffects[GameGlobals.GlobalSoundEffect.NOISE]

signal frequency_selected(frequency: String)

var is_shaking: bool = false

var shake_intensity: float = 0.1
var shake_speed: float = 10.0
var shake_timer: float = 0.0
var original_position: Vector3

func _ready() -> void:
	reset_selection()
	item_info.visible = false
	original_position = global_transform.origin


func _process(delta):
	if is_shaking:
		shake_timer += delta * shake_speed

		var offset = Vector3(
			sin(shake_timer * 1.1),
			cos(shake_timer * 1.7),
			sin(shake_timer * 1.3 + PI / 4)
		) * shake_intensity

		global_transform.origin = original_position + offset


func _on_static_body_3d_input_event(
	_camera: Node,
	event: InputEvent,
	_event_position: Vector3,
	_normal: Vector3,
	_shape_idx: int
) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			item_info.visible = true
			is_shaking = false
			noise_sfx.play()
			sine_sfx.play()
			_on_frequency_slider_value_changed(reset_selection())
			

func _on_back_pressed() -> void:
	item_info.visible = false
	noise_sfx.stop()
	sine_sfx.stop()


func _on_frequency_slider_value_changed(value: float) -> void:
	var a: float = 111
	var b: float = 125
	if (value < 111):
		a = 100 / 2.0
		b = 111
	if (value >= 111 and value < 125):
		a = 111
		b = 125
	elif (value >= 125 and value < 157):
		a = 125
		b = 157
	elif (value >= 157 and value < 179):
		a = 157
		b = 179
	elif (value >= 179):
		a = 179
		b = 199 * 2


	var midpoint: float = (b - a) / 2.0
	var distance_to_midpoint = abs(midpoint - value);
	var interpolation = abs((distance_to_midpoint - a) / (b - a)) * 2

	# just one more interpolation bro i swear
	
	var noise_volume = (0 - 80) * interpolation
	var sine_volume = -80 - (noise_volume)

	sine_sfx.volume_db = sine_volume - 10
	noise_sfx.volume_db = noise_volume

	frequency_label.text = str(int(value)) + " kHz"


func _on_confirm_pressed() -> void:
	emit_signal("frequency_selected", str(int(frequency_slider.value)))
	item_info.visible = false
	reset_selection()
	noise_sfx.stop()
	sine_sfx.stop()


func reset_selection() -> int:
	var random_frequency = randi() % 99 + 101
	frequency_slider.value = random_frequency
	frequency_label.text = str(random_frequency) + " kHz"
	return random_frequency


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and item_info.visible:
		item_info.visible = false
		reset_selection()


func _on_static_body_3d_mouse_exited() -> void:
	is_shaking = false


func _on_static_body_3d_mouse_entered() -> void:
	is_shaking = true
