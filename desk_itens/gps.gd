extends Node3D

@onready var grid_container: GridContainer = %GridContainer
var selected_button: String

signal gps_selected(coordinate: String)

func _ready() -> void:
	for child in grid_container.get_children():
		if child is Button:
			child.pressed.connect(func(): _on_grid_button_pressed(child.name))


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


func _on_grid_button_pressed(button_name: String) -> void:
	if selected_button:
		var btn = grid_container.get_node(selected_button)
		if btn is Button:
			btn.button_pressed = false
	selected_button = button_name


func _on_confirm_pressed() -> void:
	gps_selected.emit(selected_button)
	$ItemInfo.visible = false
