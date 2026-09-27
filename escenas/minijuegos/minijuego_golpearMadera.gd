extends Node2D

signal termino(resultado: float)

@export var tiempoLimite: float = 8.0
@export var velocidadBarra: float = 7.0
@export var zona_roja_min: float = 0.75
@export var zona_roja_max: float = 1.0
@export var tiempo_mostrar_resultado: float = 1.0
@export var textura1: Texture2D
@export var textura2: Texture2D
@export var textura3: Texture2D

var puedeGolpear: bool = false
var tiempo_transcurrido: float = 0.0
var potenciaActual: float = 0.0
var yaGolpeo: bool = false
var segmentos: Array[ColorRect] = []

func _ready() -> void:
	segmentos = [$Fuerza1, $Fuerza2, $Fuerza3, $Fuerza4, $Fuerza5, $Fuerza6, $Fuerza7, $Fuerza8, $Fuerza9, $Fuerza10]
	$Instruccion.text = "GOLPEÁ LA MADERA"
	$ProgressBar.min_value = 0.0
	$ProgressBar.max_value = 1.0

	$Timer.wait_time = tiempoLimite
	$Timer.one_shot = true
	$Timer.timeout.connect(_cuando_se_acaba_el_tiempo)
	$Timer.start()

	puedeGolpear = true
	
	await get_tree().create_timer(2.0).timeout
	$Instruccion.text = ""

func _process(delta: float) -> void:
	if $Timer.time_left > 0:
		$ProgressBar.value = $Timer.time_left / tiempoLimite
	else:
		$ProgressBar.value = 0.0

	if not puedeGolpear:
		return

	tiempo_transcurrido += delta
	potenciaActual = (1.0 - cos(tiempo_transcurrido * velocidadBarra)) / 2.0

	if Input.is_action_just_pressed("ui_accept") and not yaGolpeo:
		_golpear()

	_actualizar_segmentos()

func _animar_golpe(acerto: bool) -> void:
	if acerto:
		$Personaje.texture = textura2
	else:
		$Personaje.texture = textura3
	await get_tree().create_timer(0.15).timeout

func _golpear() -> void:
	yaGolpeo = true
	puedeGolpear = false
	$Timer.stop()

	var acerto: bool = potenciaActual >= zona_roja_min and potenciaActual <= zona_roja_max
	_animar_golpe(acerto)

	var resultado: float

	if acerto:
		resultado = 1.0
	else:
		var distancia: float = min(abs(potenciaActual - zona_roja_min), abs(potenciaActual - zona_roja_max))
		resultado = clamp(1.0 - distancia * 2.0, 0.0, 0.9)

	await get_tree().create_timer(tiempo_mostrar_resultado).timeout
	terminar(resultado)

func _cuando_se_acaba_el_tiempo() -> void:
	if yaGolpeo:
		return
	yaGolpeo = true
	puedeGolpear = false
	$Mensaje.text = "¡Se acabó el tiempo!"
	await get_tree().create_timer(tiempo_mostrar_resultado).timeout
	terminar(0.0)

func _actualizar_segmentos() -> void:
	var segmentos_prendidos: int = round(potenciaActual * segmentos.size())
	for i in segmentos.size():
		segmentos[i].visible = i < segmentos_prendidos

func terminar(resultado: float) -> void:
	termino.emit(resultado)
	queue_free()
