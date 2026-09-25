extends Area2D

signal atrapo_objeto(objeto: Node2D)

@export var velocidad: float = 500.0
@export var margen: float = 50.0

var limite_izquierdo: float
var limite_derecho: float

func _ready() -> void:
	var ancho_pantalla: float = get_viewport_rect().size.x
	limite_izquierdo = margen
	limite_derecho = ancho_pantalla - margen

func _process(delta: float) -> void:
	var direccion: float = 0.0
	if Input.is_action_pressed("ui_left"):
		direccion -= 1.0
	if Input.is_action_pressed("ui_right"):
		direccion += 1.0

	global_position.x += direccion * velocidad * delta
	global_position.x = clamp(global_position.x, limite_izquierdo, limite_derecho)

func _on_area_entered(area: Area2D) -> void:
	atrapo_objeto.emit(area)
