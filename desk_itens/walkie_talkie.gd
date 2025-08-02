extends Node3D

@onready var frequency_label: Label = %FrequencyLabel
@onready var frequency_slider: HScrollBar = %FrequencySlider
@onready var item_info: CanvasLayer = $ItemInfo

signal frequency_selected(frequency: String)


func _ready() -> void:
	reset_selection()
	item_info.visible = false
	

func _on_static_body_3d_input_event(
	_camera: Node,
	event: InputEvent,
	_event_position: Vector3,
	_normal: Vector3,
	_shape_idx: int
) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			$ItemInfo.visible = true


func _on_back_pressed() -> void:
	$ItemInfo.visible = false


func _on_frequency_slider_value_changed(value: float) -> void:
	frequency_label.text = str(int(value)) + " kHz"


func _on_confirm_pressed() -> void:
	emit_signal("frequency_selected", str(int(frequency_slider.value)))
	$ItemInfo.visible = false
	reset_selection()


func reset_selection() -> void:
	var random_frequency = randi() % 99 + 101
	frequency_slider.value = random_frequency
	frequency_label.text = str(random_frequency) + " kHz"
