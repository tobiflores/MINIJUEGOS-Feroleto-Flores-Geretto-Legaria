extends Node2D

const ESCENA_RUN := "res://escenas/general/principal.tscn"

var entro: bool = false

func _on_puerta_body_entered(_body: Node2D) -> void:
	if entro:
		return
	entro = true
	get_tree().change_scene_to_file(ESCENA_RUN)
