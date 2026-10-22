extends Node2D

signal termino(resultado: float)

@export var minijuegoPuerta: PackedScene

var entro: bool = false

func _on_puerta_body_entered(_body: Node2D) -> void:
	if entro:
		return
	entro = true

	$Habitacion.hide()
	$Jugador.hide()
	$Jugador.set_physics_process(false)

	var minijuego: Node = minijuegoPuerta.instantiate()
	add_child(minijuego)
	minijuego.termino.connect(_cuando_termina_minijuego)

func _cuando_termina_minijuego(resultado: float) -> void:
	termino.emit(resultado)
	queue_free()
