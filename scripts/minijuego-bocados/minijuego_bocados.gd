extends Node2D

signal termino(resultado: float)

@export var tiempo_limite: float = 16.0
@export var objetivo_bocados: int = 2
@export var velocidad_caida: float = 130.0
@export var municion_maxima: int = 5
@export var framesBocado: SpriteFrames = preload("res://imagenes/anim/bocado_frames.tres")

const INTERVALO_ACELERACION: float = 0.33
const FACTOR_ACELERACION: float = 1.25

var textura_mascota: Texture2D = null
var tipo_animal: String = ""

@onready var balde: Sprite2D = $Balde
@onready var animal: Sprite2D = $Animal
@onready var etiqueta_timer: Label = $Interfaz/EtiquetaTimer
@onready var etiqueta_info: Label = $Interfaz/EtiquetaInfo

var ancho: float = 1152.0
var alto: float = 648.0
var terminado: bool = false

var velocidad_animal: float = 200.0
var direccion: float = 1.0
var patron: String = "lineal"
var fase: float = 0.0
var cambio_en: float = 0.0

var bocados: Array[AnimatedSprite2D] = []
var comidos: int = 0
var restante: float = 0.0

var municion: int = 0
var regen_en: float = 0.0

func _ready() -> void:
	var tamano: Vector2 = get_viewport_rect().size
	ancho = tamano.x
	alto = tamano.y
	restante = tiempo_limite
	etiqueta_timer.text = str(int(ceil(restante)))

	municion = municion_maxima

	var tipos := {
		"gato": [180.0, "lineal"],
		"perro": [240.0, "nervioso"],
		"conejo": [320.0, "ondulado"],
	}
	var tipo: String = _tipo_movimiento(tipo_animal)
	if tipo == "":
		var nombres: Array = tipos.keys()
		tipo = nombres[randi() % nombres.size()]
	velocidad_animal = tipos[tipo][0]
	patron = tipos[tipo][1]

	if textura_mascota != null:
		animal.texture = textura_mascota
		var tam: Vector2 = textura_mascota.get_size()
		if tam.x > 0.0:
			var factor: float = 90.0 / tam.x
			animal.scale = Vector2(factor, factor)

	animal.position = Vector2(ancho * 0.5, alto - 140)
	cambio_en = randf_range(0.3, 0.9)
	_actualizar_info()

func _tipo_movimiento(nombre: String) -> String:
	if nombre in ["gato", "gato_gordo", "officecats"]:
		return "gato"
	if nombre in ["perro", "amigo"]:
		return "perro"
	if nombre in ["conejo", "conejo_cool"]:
		return "conejo"
	return ""

func _process(delta: float) -> void:
	if terminado:
		return

	restante -= delta
	etiqueta_timer.text = str(maxi(int(ceil(restante)), 0))
	if restante <= 0.0:
		_terminar(0.0, "SE FUE...")
		return

	regen_en += delta
	if regen_en >= 1.0:
		regen_en -= 1.0
		if municion < municion_maxima:
			municion += 1
			_actualizar_info()

	var mouse_x: float = clampf(get_global_mouse_position().x, 55.0, ancho - 55.0)
	balde.position.x = mouse_x

	_mover_animal(delta)
	_mover_bocados(delta)

func _mover_animal(delta: float) -> void:
	if patron == "ondulado":
		fase += delta * 4.0
		animal.position.x += direccion * velocidad_animal * delta * (0.6 + 0.4 * sin(fase))
	elif patron == "nervioso":
		cambio_en -= delta
		if cambio_en <= 0.0:
			if randf() < 0.5:
				direccion = -direccion
			cambio_en = randf_range(0.3, 0.9)
		animal.position.x += direccion * velocidad_animal * delta
	else:
		animal.position.x += direccion * velocidad_animal * delta

	if animal.position.x < 50:
		animal.position.x = 50
		direccion = 1.0
	elif animal.position.x > ancho - 50:
		animal.position.x = ancho - 50
		direccion = -1.0

func _mover_bocados(delta: float) -> void:
	var caja := Rect2(animal.position - Vector2(45, 40), Vector2(90, 80))
	for bocado in bocados.duplicate():
		var vel: float = bocado.get_meta("vel")
		var acelera_en: float = bocado.get_meta("acelera_en") - delta
		while acelera_en <= 0.0:
			acelera_en += INTERVALO_ACELERACION
			vel *= FACTOR_ACELERACION
		bocado.set_meta("vel", vel)
		bocado.set_meta("acelera_en", acelera_en)

		bocado.position.y += vel * delta
		if caja.has_point(bocado.position):
			bocados.erase(bocado)
			bocado.queue_free()
			comidos += 1
			_actualizar_info()
			if comidos >= objetivo_bocados:
				_terminar(1.0, "¡LO LOGRASTE!")
		elif bocado.position.y > alto:
			bocados.erase(bocado)
			bocado.queue_free()

func _unhandled_input(evento: InputEvent) -> void:
	if terminado:
		return
	if evento is InputEventMouseButton and evento.pressed and evento.button_index == MOUSE_BUTTON_LEFT:
		if municion <= 0:
			return
		municion -= 1
		var bocado := AnimatedSprite2D.new()
		bocado.sprite_frames = framesBocado
		bocado.scale = Vector2(0.4, 0.4)
		bocado.position = balde.position + Vector2(0, 40)
		bocado.set_meta("vel", velocidad_caida)
		bocado.set_meta("acelera_en", INTERVALO_ACELERACION)
		add_child(bocado)
		bocado.play("default")
		bocados.append(bocado)
		_actualizar_info()

func _actualizar_info() -> void:
	etiqueta_info.text = "Bocados: %d\nAtrapados: %d / %d" % [municion, comidos, objetivo_bocados]

func _terminar(resultado: float, mensaje: String) -> void:
	if terminado:
		return
	terminado = true
	etiqueta_info.text = mensaje
	await get_tree().create_timer(1.0).timeout
	termino.emit(resultado)
	queue_free()
