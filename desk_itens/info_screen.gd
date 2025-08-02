extends Node3D

@onready var label_status: Label3D = %LabelStatus
@onready var label_score: Label3D = %LabelScore
@onready var label_objective: Label3D = %LabelObjective

@onready var status_timer: Timer = $StatusTimer


func _ready() -> void:
	label_status.visible = false
	label_score.text = "Score: 0"


func update_score(score, threshold := 0, objective := "Score") -> void:
	if threshold:
		label_score.text = "(" + str(score) + " / " + str(threshold) + ")"
	else:
		label_score.text = str(score)

	label_objective.text = objective


func show_status(text: String) -> void:
	label_status.text = text
	label_status.visible = true
	status_timer.start()


func _on_status_timer_timeout() -> void:
	label_status.visible = false
