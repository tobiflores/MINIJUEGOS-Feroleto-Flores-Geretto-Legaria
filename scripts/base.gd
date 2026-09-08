extends Node2D

signal termino(resultado: float)

@export var tiempoLimite: float = 5.0

func _ready() -> void:
	$Timer.wait_time = tiempoLimite
	$Timer.one_shot = true
	$Timer.timeout.connect(tiempoLimite)
	$Timer.start()

func limiteAlcanzado() -> void:
	terminar(0.0)

func terminar(resultado: float) -> void:
	termino.emit(resultado)
	queue_free()
