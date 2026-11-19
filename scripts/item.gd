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
	if not mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.connect(_on_mouse_entered)
	if not mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	$Tooltip.show()

func _on_mouse_exited() -> void:
	$Tooltip.hide()

func _unhandled_input(evento: InputEvent) -> void:
	if not $Tooltip.visible or not evento.is_action_pressed("interactuar"):
		return
	get_viewport().set_input_as_handled()
	recogido.emit(nombre)
	queue_free()
