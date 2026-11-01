extends Node2D

signal termino(resultado: float)

@export var tiempo_limite: float = 15.0
@export var texturaCursor: Texture2D

const MITAD_CASILLA: float = 60.0

@onready var barra_tiempo: ProgressBar = $ProgressBar
@onready var etiqueta_info: Label = $Interfaz/EtiquetaInfo
@onready var casillas: Array[Node] = $Casillas.get_children()

var giros: Array[int] = []
var angulos: Array[float] = []
var terminado: bool = false

func _ready() -> void:
	barra_tiempo.value = barra_tiempo.max_value
	Input.set_custom_mouse_cursor(texturaCursor)

	for casilla in casillas:
		giros.append(randi_range(1, 3))
	if randf() < 0.5:
		giros[randi() % giros.size()] = 0

	for indice in casillas.size():
		var angulo: float = giros[indice] * 90.0
		angulos.append(angulo)
		casillas[indice].get_node("Flecha").rotation_degrees = angulo

func _process(delta: float) -> void:
	if terminado:
		return

	barra_tiempo.value -= delta / tiempo_limite * barra_tiempo.max_value
	if barra_tiempo.value <= 0.0:
		_terminar(0.0, "¡NO ENCONTRÓ LA SALIDA!")

func _unhandled_input(evento: InputEvent) -> void:
	if terminado:
		return
	if not (evento is InputEventMouseButton and evento.pressed):
		return

	var sentido: int = 0
	if evento.button_index == MOUSE_BUTTON_LEFT:
		sentido = 1
	elif evento.button_index == MOUSE_BUTTON_RIGHT:
		sentido = -1
	if sentido == 0:
		return

	for indice in casillas.size():
		var local: Vector2 = casillas[indice].to_local(get_global_mouse_position())
		if absf(local.x) < MITAD_CASILLA and absf(local.y) < MITAD_CASILLA:
			_girar(indice, sentido)
			break

func _girar(indice: int, sentido: int) -> void:
	giros[indice] = posmod(giros[indice] + sentido, 4)
	angulos[indice] += sentido * 90.0
	var tween: Tween = create_tween()
	tween.tween_property(casillas[indice].get_node("Flecha"), "rotation_degrees", angulos[indice], 0.1)

	if giros.all(func(g: int) -> bool: return g == 0):
		_terminar(1.0, "¡ENCONTRÓ LA SALIDA!")

func _terminar(resultado: float, mensaje: String) -> void:
	terminado = true
	Input.set_custom_mouse_cursor(null)
	etiqueta_info.text = mensaje
	await get_tree().create_timer(1.0).timeout
	termino.emit(resultado)
	queue_free()
