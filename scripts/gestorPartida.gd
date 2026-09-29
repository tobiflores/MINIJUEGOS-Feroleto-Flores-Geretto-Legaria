extends Node

var pisoActual: int = 20
var vidas: int = 3

func resultado(resultado_minijuego: float) -> void:
	var gano: bool = resultado_minijuego >= 1.0

	if gano:
		pisoActual -= 1
	else:
		vidas -= 1

	await mostrar_transicion(gano)

func mostrar_transicion(gano: bool) -> void:
	var transicion = preload("res://escenas/general/transicion.tscn").instantiate()
	add_child(transicion)
	transicion.mostrar_datos(pisoActual, vidas, gano)
	await transicion.transicion_terminada
