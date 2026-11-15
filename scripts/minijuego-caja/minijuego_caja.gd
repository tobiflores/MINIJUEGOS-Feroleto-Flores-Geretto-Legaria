extends Node2D

signal termino(resultado: float)

@export var largo_base: int = 4
@export var largo_maximo: int = 8
@export var segundos_por_paso: float = 1.5
@export var segundos_extra: float = 2.0
@export var tiempo_encendido: float = 0.45
@export var tiempo_pausa: float = 0.2
@export var texturaCursor: Texture2D

@onready var barra_tiempo: ProgressBar = $ProgressBar
@onready var etiqueta_info: Label = $Interfaz/EtiquetaInfo
@onready var botones: Array[Node] = $Botones.get_children()
@onready var puerta_caja: ColorRect = $Caja/Puerta

var secuencia: Array[int] = []
var posicion: int = 0
var tiempo_limite: float = 0.0
var turno_jugador: bool = false
var terminado: bool = false

func _ready() -> void:
	Input.set_custom_mouse_cursor(texturaCursor)

	var dificultad: float = gestorPartida.factor_dificultad()
	tiempo_encendido = maxf(tiempo_encendido / dificultad, 0.2)
	tiempo_pausa = maxf(tiempo_pausa / dificultad, 0.1)

	var largo: int = mini(largo_base + gestorPartida.pisos_bajados, largo_maximo)
	for i in largo:
		secuencia.append(randi_range(0, botones.size() - 1))
	tiempo_limite = largo * segundos_por_paso + segundos_extra
	barra_tiempo.value = barra_tiempo.max_value

	_mostrar_secuencia()

func _mostrar_secuencia() -> void:
	etiqueta_info.text = "MEMORIZÁ LA COMBINACIÓN"
	await get_tree().create_timer(0.8).timeout
	for indice in secuencia:
		await _encender(botones[indice])
		await get_tree().create_timer(tiempo_pausa).timeout
	etiqueta_info.text = "¡AHORA VOS!"
	turno_jugador = true

func _encender(boton: CanvasItem) -> void:
	boton.modulate = Color(1.8, 1.8, 1.8)
	await get_tree().create_timer(tiempo_encendido).timeout
	boton.modulate = Color.WHITE

func _process(delta: float) -> void:
	if terminado or not turno_jugador:
		return

	barra_tiempo.value -= delta / tiempo_limite * barra_tiempo.max_value
	if barra_tiempo.value <= 0.0:
		_terminar(0.0, "SE ACABÓ EL TIEMPO")

func _unhandled_input(evento: InputEvent) -> void:
	if terminado or not turno_jugador:
		return
	if not (evento is InputEventMouseButton and evento.pressed and evento.button_index == MOUSE_BUTTON_LEFT):
		return

	for indice in botones.size():
		var boton: ColorRect = botones[indice]
		if Rect2(boton.global_position, boton.size).has_point(get_global_mouse_position()):
			_presionar(indice)
			break

func _presionar(indice: int) -> void:
	_encender(botones[indice])
	if indice != secuencia[posicion]:
		_terminar(0.0, "COMBINACIÓN INCORRECTA")
		return
	posicion += 1
	if posicion >= secuencia.size():
		_abrir_caja()

func _abrir_caja() -> void:
	terminado = true
	Input.set_custom_mouse_cursor(null)
	etiqueta_info.text = "¡SE ABRIÓ!"
	var tween: Tween = create_tween()
	tween.tween_property(puerta_caja, "size:x", 30.0, 0.5)
	await tween.finished
	termino.emit(1.0)

func _terminar(resultado: float, mensaje: String) -> void:
	terminado = true
	Input.set_custom_mouse_cursor(null)
	etiqueta_info.text = mensaje
	termino.emit(resultado)
