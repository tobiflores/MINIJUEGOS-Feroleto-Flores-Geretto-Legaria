extends Node2D

const ESCENA_ITEM := preload("res://escenas/general/item.tscn")

func _ready() -> void:
	_spawn_item()

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

func _on_item_recogido(nombre: String) -> void:
	gestorPartida.aplicar_efecto_item(nombre)

func _unhandled_input(evento: InputEvent) -> void:
	if not evento.is_action_pressed("interactuar") or not has_node("FlechaAbajo"):
		return
	var colision: CollisionShape2D = $FlechaAbajo/CollisionShape2D
	if not colision.shape.get_rect().has_point(colision.get_local_mouse_position()):
		return
	get_viewport().set_input_as_handled()
	queue_free()
