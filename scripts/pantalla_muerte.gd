extends Control

const ESCENA_REINTENTAR: String = "res://escenas/general/principal.tscn"
const ESCENA_MENU: String = "res://escenas/general/menu.tscn"

@onready var estadisticas: Label = $Estadisticas

func _ready() -> void:
	estadisticas.text = "Vecinos ayudados: %d\nPisos bajados: %d" % [
		gestorPartida.vecinos_ayudados,
		gestorPartida.pisos_bajados,
	]
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.8)

func _on_reintentar_pressed() -> void:
	gestorPartida.reiniciar_run()
	get_tree().change_scene_to_file(ESCENA_REINTENTAR)

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file(ESCENA_MENU)
