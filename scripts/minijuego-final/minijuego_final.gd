extends Node2D

const ESCENA_DIARIO: String = "res://escenas/general/diario.tscn"
const TAMANO_VENTANA: Vector2 = Vector2(100, 90)
const ESCALA_LLAMA: float = 2.0
const COLOR_APAGADO: Color = Color(0.18, 0.18, 0.22)

@export var segundos_para_apagar: float = 0.9
@export var texturaCursor: Texture2D

@onready var ventanas: Array[Node] = $Edificio/Ventanas.get_children()
@onready var chorro: Line2D = $Chorro
@onready var salpicadura: ColorRect = $Salpicadura
@onready var origen_chorro: Marker2D = $OrigenChorro
@onready var etiqueta_llamas: Label = $Interfaz/EtiquetaLlamas
@onready var etiqueta_info: Label = $Interfaz/EtiquetaInfo
@onready var oscuro: ColorRect = $Interfaz/Oscuro
@onready var cartel_fin: Label = $Interfaz/Fin

var progreso: Array[float] = []
var apagadas: Array[bool] = []
var llamas_restantes: int = 0
var terminado: bool = false

func _ready() -> void:
	Input.set_custom_mouse_cursor(texturaCursor)
	for ventana in ventanas:
		progreso.append(0.0)
		apagadas.append(false)
	llamas_restantes = ventanas.size()
	_actualizar_contador()

func _process(delta: float) -> void:
	if terminado:
		return

	var apuntando: bool = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	chorro.visible = apuntando
	salpicadura.visible = apuntando
	if not apuntando:
		return

	var mouse: Vector2 = get_global_mouse_position()
	chorro.points = PackedVector2Array([origen_chorro.global_position, mouse])
	salpicadura.position = mouse - salpicadura.size / 2.0

	for indice in ventanas.size():
		if apagadas[indice]:
			continue
		var ventana: Node2D = ventanas[indice]
		if Rect2(ventana.global_position, TAMANO_VENTANA).has_point(mouse):
			progreso[indice] += delta / segundos_para_apagar
			ventana.get_node("Llama").scale = Vector2.ONE * ESCALA_LLAMA * maxf(1.0 - progreso[indice], 0.0)
			if progreso[indice] >= 1.0:
				_apagar(indice)

func _apagar(indice: int) -> void:
	apagadas[indice] = true
	var ventana: Node2D = ventanas[indice]
	ventana.get_node("Llama").hide()
	ventana.get_node("Vidrio").color = COLOR_APAGADO
	llamas_restantes -= 1
	_actualizar_contador()
	if llamas_restantes <= 0:
		_terminar()

func _actualizar_contador() -> void:
	etiqueta_llamas.text = "LLAMAS: %d" % llamas_restantes

func _terminar() -> void:
	terminado = true
	Input.set_custom_mouse_cursor(null)
	chorro.hide()
	salpicadura.hide()
	etiqueta_info.text = ""

	oscuro.show()
	create_tween().tween_property(oscuro, "color:a", 0.85, 0.6)
	cartel_fin.show()
	create_tween().tween_property(cartel_fin, "scale", Vector2.ONE, 0.6) \
			.from(Vector2(0.2, 0.2)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file(ESCENA_DIARIO)
