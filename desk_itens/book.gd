extends Node3D

var was_pressed = false


func _on_static_body_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			on_book_click()


func on_book_click():
	print("on click")
	$BookInfo.visible = true
