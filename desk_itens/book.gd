extends Node3D

var was_pressed = false

@onready var item_info: CanvasLayer = $ItemInfo
@onready var mesh_instance: MeshInstance3D = $BookMesh

@onready var pages_container: MarginContainer = %PagesContainer
@onready var buttons_container: HBoxContainer = %ButtonsContainer

@onready var instructions: Label = %Instructions

var current_page: int = 0
var is_shaking: bool = false

var shake_intensity: float = 0.1
var shake_speed: float = 10.0
var shake_timer: float = 0.0
var original_position: Vector3

func _ready() -> void:
	item_info.visible = false
		
	for i in buttons_container.get_child_count():
		var btn = buttons_container.get_child(i)
		if btn is Button:
			btn.pressed.connect(func(): _on_button_pressed(i))

	for j in pages_container.get_child_count():
		var page = pages_container.get_child(j)
		page.visible = (j == current_page)
	
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


func _on_button_pressed(index: int) -> void:
	for i in buttons_container.get_child_count():
		var btn = buttons_container.get_child(i)
		if btn is Button:
			btn.button_pressed = (i == index)

	for j in pages_container.get_child_count():
		var page = pages_container.get_child(j)
		page.visible = (j == index)

	current_page = index


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


func _on_back_pressed() -> void:
	item_info.visible = false


func set_instructions(instructions_text: String) -> void:
	"""
	Sets the instructions text for the book.
	"""
	instructions.text = instructions_text
	

func unlock_page(page_index: int) -> void:
	if page_index < buttons_container.get_child_count():
		var btn = buttons_container.get_child(page_index)
		if btn is Button:
			if btn.disabled:
				btn.disabled = false
				_on_button_pressed(page_index)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and item_info.visible:
		item_info.visible = false


func _on_static_body_3d_mouse_exited() -> void:
	is_shaking = false


func _on_static_body_3d_mouse_entered() -> void:
	is_shaking = true
