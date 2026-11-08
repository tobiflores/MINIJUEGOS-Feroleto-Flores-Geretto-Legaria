extends Node2D

signal termino(resultado: float)

@export var tiempo_limite: float = 6.0
@export var aumento_por_toque: float = 0.08
@export var perdida_por_segundo: float = 0.3
@export var texturaCursor: Texture2D

@onready var barra_tiempo: ProgressBar = $ProgressBar
@onready var barra_despierto: ProgressBar = $Interfaz/BarraDespierto
@onready var etiqueta_info: Label = $Interfaz/EtiquetaInfo
@onready var cama: Node2D = $Cama
@onready var zzz: Label = $Cama/Zzz
@onready var ojos_cerrados: Node2D = $Cama/Durmiente/OjosCerrados
@onready var ojos_abiertos: Node2D = $Cama/Durmiente/OjosAbiertos

var despierto: float = 0.0
var terminado: bool = false
var posicion_cama: Vector2 = Vector2.ZERO

func _ready() -> void:
	posicion_cama = cama.position
	barra_tiempo.value = barra_tiempo.max_value
	barra_despierto.value = 0.0
	Input.set_custom_mouse_cursor(texturaCursor)

func _process(delta: float) -> void:
	if terminado:
		return

	despierto = maxf(despierto - perdida_por_segundo * delta, 0.0)
	_actualizar_despierto()

	barra_tiempo.value -= delta / tiempo_limite * barra_tiempo.max_value
	if barra_tiempo.value <= 0.0:
		_terminar(0.0, "¡SIGUE DORMIDO!")

func _unhandled_input(evento: InputEvent) -> void:
	if terminado:
		return
	var toque: bool = false
	if evento is InputEventMouseButton and evento.pressed and evento.button_index == MOUSE_BUTTON_LEFT:
		toque = true
	elif evento is InputEventKey and evento.pressed and not evento.echo and evento.physical_keycode == KEY_SPACE:
		toque = true
	if toque:
		_tocar()

func _tocar() -> void:
	despierto = minf(despierto + aumento_por_toque, 1.0)
	_actualizar_despierto()
	_sacudir()
	if despierto >= 1.0:
		ojos_cerrados.hide()
		ojos_abiertos.show()
		_terminar(1.0, "¡SE DESPERTÓ!")

func _sacudir() -> void:
	cama.position = posicion_cama + Vector2(randf_range(-6.0, 6.0), 0.0)
	var tween: Tween = create_tween()
	tween.tween_property(cama, "position", posicion_cama, 0.05)

func _actualizar_despierto() -> void:
	barra_despierto.value = despierto
	zzz.modulate.a = 1.0 - despierto

func _terminar(resultado: float, mensaje: String) -> void:
	terminado = true
	Input.set_custom_mouse_cursor(null)
	etiqueta_info.text = mensaje
	await get_tree().create_timer(1.0).timeout
	termino.emit(resultado)
	queue_free()
