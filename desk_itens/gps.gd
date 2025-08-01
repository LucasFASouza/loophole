extends Node3D

@onready var grid_container: GridContainer = %GridContainer
var selected_button: String

func _ready() -> void:
	for child in grid_container.get_children():
		if child is Button:
			child.pressed.connect(func(): _on_grid_button_pressed(child.name))


func _on_grid_button_pressed(button_name: String) -> void:
	if selected_button:
		var btn = grid_container.get_node(selected_button)
		if btn is Button:
			btn.button_pressed = false
	selected_button = button_name


func _on_confirm_pressed() -> void:
	print("Confirmed button: ", selected_button)
