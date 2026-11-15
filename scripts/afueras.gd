extends Node2D

const ESCENA_FINAL: String = "res://escenas/minijuegos/minijuego_final.tscn"

@export var distancia_abordaje: float = 150.0

@onready var jugador: CharacterBody2D = $Jugador
@onready var camion: Node2D = $Camion
@onready var punto_abordaje: Marker2D = $Camion/PuntoAbordaje
@onready var etiqueta_aviso: Label = $Interfaz/EtiquetaAviso

var abordando: bool = false

func _process(_delta: float) -> void:
	if abordando:
		return
	if jugador.global_position.distance_to(punto_abordaje.global_position) < distancia_abordaje:
		_abordar()

func _abordar() -> void:
	abordando = true
	jugador.hide()
	jugador.set_physics_process(false)
	etiqueta_aviso.text = "¡A APAGAR EL INCENDIO!"
	var tween: Tween = create_tween()
	tween.tween_property(camion, "position:x", camion.position.x + 60.0, 0.7)
	await tween.finished
	get_tree().change_scene_to_file(ESCENA_FINAL)
