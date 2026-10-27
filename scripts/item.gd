extends Area2D

signal recogido(nombre: String)

var nombre: String = ""

func configurar(nombre_item: String) -> void:
	nombre = nombre_item
	var info: Dictionary = gestorPartida.info_item(nombre)

	var ruta: String = info.get("textura", "")
	if ruta != "" and ResourceLoader.exists(ruta):
		$Sprite2D.texture = load(ruta)

	$Tooltip.text = info.get("desc", "")
	$Tooltip.hide()

func _ready() -> void:
	input_pickable = true
	if not input_event.is_connected(_on_input_event):
		input_event.connect(_on_input_event)
	if not mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.connect(_on_mouse_entered)
	if not mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	$Tooltip.show()

func _on_mouse_exited() -> void:
	$Tooltip.hide()

func _on_input_event(_viewport: Node, evento: InputEvent, _shape_idx: int) -> void:
	if not (evento is InputEventMouseButton):
		return
	if evento.button_index != MOUSE_BUTTON_LEFT or not evento.pressed:
		return
	recogido.emit(nombre)
	queue_free()
