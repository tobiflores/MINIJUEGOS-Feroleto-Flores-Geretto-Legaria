extends Node2D

const ESCENA_ITEM := preload("res://escenas/general/item.tscn")

func _ready() -> void:
	_spawn_item()
	_conectar_salida()

func _process(_delta: float) -> void:
	if has_node("Cursor"):
		$Cursor.global_position = get_global_mouse_position()

func _spawn_item() -> void:
	var nombre: String = gestorPartida.elegir_item_habitacion()
	if nombre == "":
		return

	var item := ESCENA_ITEM.instantiate()
	add_child(item)
	item.configurar(nombre)
	if has_node("Centro"):
		item.position = $Centro.position
	else:
		item.position = get_viewport_rect().size * 0.5
	item.recogido.connect(_on_item_recogido)

func _conectar_salida() -> void:
	if not has_node("FlechaAbajo"):
		return
	var flecha := $FlechaAbajo as Area2D
	flecha.input_pickable = true
	if not flecha.input_event.is_connected(_on_flecha_input_event):
		flecha.input_event.connect(_on_flecha_input_event)

func _on_item_recogido(nombre: String) -> void:
	gestorPartida.aplicar_efecto_item(nombre)

func _on_flecha_input_event(_viewport: Node, evento: InputEvent, _shape_idx: int) -> void:
	if not (evento is InputEventMouseButton):
		return
	if evento.button_index != MOUSE_BUTTON_LEFT or not evento.pressed:
		return
	queue_free()
