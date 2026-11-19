extends Node2D

const ESCENA_RUN := "res://escenas/general/principal.tscn"

var entro: bool = false

func _unhandled_input(event: InputEvent) -> void:
	if entro or not event.is_action_pressed("interactuar"):
		return
	if not $Puerta.overlaps_body($Jugador):
		return
	entro = true
	get_viewport().set_input_as_handled()
	get_tree().change_scene_to_file.call_deferred(ESCENA_RUN)
