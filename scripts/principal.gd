extends Node2D

@export var lista_minijuegos: Array[PackedScene] = []

var minijuegoActual: Node2D = null

func _ready() -> void:
	_cargar_minijuego_aleatorio()

func _cargar_minijuego_aleatorio() -> void:
	var escena_elegida: PackedScene = lista_minijuegos[randi() % lista_minijuegos.size()]
	minijuegoActual = escena_elegida.instantiate()
	add_child(minijuegoActual)
	minijuegoActual.termino.connect(_cuando_termina_minijuego)

func _cuando_termina_minijuego(resultado: float) -> void:
	await gestorPartida.resultado(resultado)
	_cargar_minijuego_aleatorio()
