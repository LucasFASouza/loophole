extends Node3D

@onready var item_info: CanvasLayer = $ItemInfo
@onready var grid_container: GridContainer = %GridContainer
var selected_button: String

signal gps_selected(coordinate: String)

var is_shaking: bool = false

var shake_intensity: float = 0.1
var shake_speed: float = 10.0
var shake_timer: float = 0.0
var original_position: Vector3

func _ready() -> void:
	item_info.visible = false
	for child in grid_container.get_children():
		if child is Button:
			child.pressed.connect(func(): _on_grid_button_pressed(child.name))

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


func _on_grid_button_pressed(button_name: String) -> void:
	if selected_button:
		var btn = grid_container.get_node(selected_button)
		if btn is Button:
			btn.button_pressed = false
	selected_button = button_name
	GameGlobals.play_sfx(GameGlobals.GlobalSoundEffect.BEEP_GPS)


func _on_confirm_pressed() -> void:
	gps_selected.emit(selected_button)
	item_info.visible = false
	reset_selection()


func _on_back_pressed() -> void:
	item_info.visible = false
	reset_selection()


func reset_selection() -> void:
	if selected_button:
		var btn = grid_container.get_node(selected_button)
		if btn is Button:
			btn.button_pressed = false
	selected_button = ""


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and item_info.visible:
		item_info.visible = false
		reset_selection()


func _on_static_body_3d_mouse_exited() -> void:
	is_shaking = false


func _on_static_body_3d_mouse_entered() -> void:
	is_shaking = true
