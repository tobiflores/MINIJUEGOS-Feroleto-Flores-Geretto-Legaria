extends Area2D

signal atrapo_objeto(objeto: Node2D)

@export var velocidad: float = 500.0

var limite_izquierdo: float = 50.0
var limite_derecho: float = 1100.0

func _process(delta: float) -> void:
	var direccion: float = 0.0
	if Input.is_action_pressed("ui_left"):
		direccion -= 1.0
	if Input.is_action_pressed("ui_right"):
		direccion += 1.0

	position.x += direccion * velocidad * delta
	position.x = clamp(position.x, limite_izquierdo, limite_derecho)

func _on_area_entered(area: Area2D) -> void:
	atrapo_objeto.emit(area)
