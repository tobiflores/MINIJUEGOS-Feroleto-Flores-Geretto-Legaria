extends Node2D

signal transicion_terminada

@export var duracion_bajada: float = 3.0
@export var duracion_piso: float = 1.5
@export var escalones: int = 6

@export var posicion_inicial: Vector2 = Vector2(838.0, 109.0)
@export var posicion_quiebre: Vector2 = Vector2(431.0, 447.0)
@export var posicion_final: Vector2 = Vector2(798.0, 489.0)

func _ready() -> void:
	$Personaje.position = posicion_inicial
	_animar_bajada()

func _animar_bajada() -> void:
	var tween := create_tween()

	for i in escalones:
		var progreso: float = float(i + 1) / float(escalones)
		var punto: Vector2 = Vector2.ZERO
		punto.x = lerp(posicion_inicial.x, posicion_quiebre.x, progreso)
		punto.y = lerp(posicion_inicial.y, posicion_quiebre.y, progreso)
		tween.tween_property($Personaje, "position", punto, duracion_bajada / escalones)

	tween.tween_property($Personaje, "position", posicion_final, duracion_piso)

	await tween.finished
	transicion_terminada.emit()
	# queue_free()
