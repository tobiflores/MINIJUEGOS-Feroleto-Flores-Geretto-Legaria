extends Node2D

signal rescatado(animal: Node2D)

@export var nombre: String = "gato"
@export var textura: Texture2D
@export var retardo: float = 0.5
@export var penalizacion_velocidad: float = 0.07

var objetivo: Node2D = null
var fue_rescatado: bool = false
var historial: Array = []

func _ready() -> void:
	if textura != null:
		$Sprite2D.texture = textura

func _unhandled_input(evento: InputEvent) -> void:
	if fue_rescatado or not evento.is_action_pressed("interactuar"):
		return
	if get_parent().has_node("Room"):
		return
	var jugador: CharacterBody2D = get_parent().get_node("Jugador")
	if global_position.distance_to(jugador.global_position) >= 130.0:
		return
	get_viewport().set_input_as_handled()
	fue_rescatado = true
	historial.clear()
	rescatado.emit(self)

func _process(_delta: float) -> void:
	if not fue_rescatado or objetivo == null:
		return

	var ahora: float = Time.get_ticks_msec() / 1000.0
	historial.append([ahora, objetivo.global_position])

	while historial.size() > 2 and ahora - historial[1][0] >= retardo:
		historial.pop_front()

	var muestra: Array = historial[0]
	if ahora - muestra[0] >= retardo:
		global_position = muestra[1]
