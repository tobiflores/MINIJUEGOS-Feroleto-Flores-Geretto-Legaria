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

	var area := $Area2D as Area2D
	area.input_pickable = true
	if not area.input_event.is_connected(_on_area_input_event):
		area.input_event.connect(_on_area_input_event)

func _on_area_input_event(_viewport: Node, evento: InputEvent, _shape_idx: int) -> void:
	if fue_rescatado:
		return
	if not (evento is InputEventMouseButton):
		return
	if evento.button_index != MOUSE_BUTTON_LEFT or not evento.pressed:
		return
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
