extends Control

const ESCENA_JUEGO: String = "res://escenas/general/overworld.tscn"

@onready var panel_ajustes: Control = $AjustesPanel
@onready var panel_creditos: Control = $PanelCreditos

func _on_jugar_pressed() -> void:
	gestorPartida.reiniciar_run()
	get_tree().change_scene_to_file(ESCENA_JUEGO)

func _on_ajustes_pressed() -> void:
	panel_ajustes.abrir()

func _on_creditos_pressed() -> void:
	panel_creditos.show()

func _on_creditos_volver_pressed() -> void:
	panel_creditos.hide()

func _on_salir_pressed() -> void:
	get_tree().quit()
