extends PanelContainer

signal close_controls


func _on_back_pressed() -> void:
	close_controls.emit()
