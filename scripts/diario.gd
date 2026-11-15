extends Control

const ESCENA_MENU: String = "res://escenas/general/menu.tscn"

@export var segundos_hasta_volver: float = 4.0

@onready var boton_volver: Button = $Volver
@onready var flecha: Node2D = $Flecha

func _ready() -> void:
	boton_volver.modulate.a = 0.0
	flecha.modulate.a = 0.0
	await get_tree().create_timer(segundos_hasta_volver).timeout
	boton_volver.show()
	flecha.show()
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(boton_volver, "modulate:a", 1.0, 0.6)
	tween.tween_property(flecha, "modulate:a", 1.0, 0.6)

func _on_volver_pressed() -> void:
	get_tree().change_scene_to_file(ESCENA_MENU)
