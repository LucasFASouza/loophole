extends MeshInstance3D


func _on_static_body_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	print(event)


func _on_static_body_3d_mouse_entered() -> void:
	print("mouse, on the book, on the table")


func _on_static_body_3d_mouse_exited() -> void:
	print("mouse left the book but it's still on the table")
