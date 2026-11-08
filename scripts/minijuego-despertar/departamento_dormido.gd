extends Node2D

signal termino(resultado: float)

@export var distanciaJugar: float = 230.0
@export var escenaMinijuego: PackedScene

@onready var jugador: CharacterBody2D = $Apartamento/Jugador
@onready var cama: Node2D = $Apartamento/Cama
@onready var etiqueta_jugar: Label = $Interfaz/EtiquetaJugar

var minijuegoIniciado: bool = false

func _process(_delta: float) -> void:
	if minijuegoIniciado:
		return
	etiqueta_jugar.visible = jugador.global_position.distance_to(cama.global_position) < distanciaJugar

func _unhandled_input(event: InputEvent) -> void:
	if minijuegoIniciado or not etiqueta_jugar.visible:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_E:
		_iniciar_minijuego()

func _iniciar_minijuego() -> void:
	minijuegoIniciado = true
	etiqueta_jugar.hide()
	jugador.velocity = Vector2.ZERO
	jugador.set_physics_process(false)
	$Apartamento.hide()

	var minijuego: Node = escenaMinijuego.instantiate()
	minijuego.termino.connect(_cuando_termina_minijuego)
	add_child(minijuego)

func _cuando_termina_minijuego(resultado: float) -> void:
	termino.emit(resultado)
	queue_free()
