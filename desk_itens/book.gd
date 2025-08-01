extends Node3D

var was_pressed = false

@onready var pages_container: MarginContainer = %PagesContainer
@onready var buttons_container: HBoxContainer = %ButtonsContainer
var current_page: int = 0


func _ready() -> void:
	for i in buttons_container.get_child_count():
		var btn = buttons_container.get_child(i)
		if btn is Button:
			btn.pressed.connect(func(): _on_button_pressed(i))

	for j in pages_container.get_child_count():
		var page = pages_container.get_child(j)
		page.visible = (j == current_page)


func _on_button_pressed(index: int) -> void:
	for i in buttons_container.get_child_count():
		var btn = buttons_container.get_child(i)
		if btn is Button:
			btn.button_pressed = (i == index)

	for j in pages_container.get_child_count():
		var page = pages_container.get_child(j)
		page.visible = (j == index)

	current_page = index


func _on_static_body_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			on_book_click()


func on_book_click():
	$ItemInfo.visible = true


func _on_back_pressed() -> void:
	$ItemInfo.visible = false
