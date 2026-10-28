extends Node2D

signal termino(resultado: float)

@export var tiempo_limite: float = 1.5
@export var velocidad_min: float = 350.0
@export var velocidad_max: float = 600.0
@export var texturaCursor: Texture2D

const ANCHO_GATO: float = 120.0
@onready var gato: Node2D = $Gato
@onready var barra_tiempo: ProgressBar = $ProgressBar
@onready var etiqueta_info: Label = $Interfaz/EtiquetaInfo

var direccion: float = 1.0
var velocidad: float = 400.0
var cambio_en: float = 0.0
var terminado: bool = false
var ancho: float = 1152.0
var alto: float = 648.0

func _ready() -> void:
	var tamano: Vector2 = get_viewport_rect().size
	ancho = tamano.x
	alto = tamano.y
	barra_tiempo.value = barra_tiempo.max_value
	Input.set_custom_mouse_cursor(texturaCursor)

	velocidad = randf_range(velocidad_min, velocidad_max)
	_reprogramar_cambio()

func _process(delta: float) -> void:
	if terminado:
		return

	gato.position.x += direccion * velocidad * delta
	var margen: float = ANCHO_GATO * 0.75
	if gato.position.x > ancho - margen:
		gato.position.x = ancho - margen
		direccion = -1.0
	elif gato.position.x < margen:
		gato.position.x = margen
		direccion = 1.0
	gato.scale.x = direccion

	cambio_en -= delta
	if cambio_en <= 0.0:
		velocidad = randf_range(velocidad_min, velocidad_max)
		if randf() < 0.4:
			direccion = -direccion
		_reprogramar_cambio()

	barra_tiempo.value -= delta / tiempo_limite * barra_tiempo.max_value
	if barra_tiempo.value <= 0.0:
		_terminar(0.0, "¡SE ESCAPÓ!")

func _unhandled_input(evento: InputEvent) -> void:
	if terminado:
		return
	if evento is InputEventMouseButton and evento.pressed and evento.button_index == MOUSE_BUTTON_LEFT:
		var caja := Rect2(gato.position + Vector2(-85, -38), Vector2(155, 118))
		if gato.scale.x < 0.0:
			caja = Rect2(gato.position + Vector2(-70, -38), Vector2(155, 118))
		if caja.has_point(get_global_mouse_position()):
			_terminar(1.0, "¡ATRAPADO!")

func _terminar(resultado: float, mensaje: String) -> void:
	terminado = true
	Input.set_custom_mouse_cursor(null)
	etiqueta_info.text = mensaje
	await get_tree().create_timer(1.0).timeout
	termino.emit(resultado)
	queue_free()

func _reprogramar_cambio() -> void:
	cambio_en = randf_range(0.4, 1.0)
