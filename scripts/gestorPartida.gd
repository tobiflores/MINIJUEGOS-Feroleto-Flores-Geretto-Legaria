extends Node

var pisoActual: int = 1
var peligroActual: float = 0.0

func resultado(resultado: float) -> void:
	peligroActual += (1.0 - resultado) * 0.2
	peligroActual = clamp(peligroActual, 0.0, 1.0)
	if peligroActual >= 1.0:
		print("perdiste")
	else:
		pisoActual += 1
		print("bajaste al piso ", pisoActual)
