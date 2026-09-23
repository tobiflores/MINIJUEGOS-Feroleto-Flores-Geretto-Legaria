extends Node2D

signal termino(resultado: float)

@export var tiempoLimite: float = 15.0
@export var tiempo_entre_apariciones_min: float = 0.4
@export var tiempo_entre_apariciones_max: float = 0.9
@export var velocidad_caida_min: float = 150.0
@export var velocidad_caida_max: float = 300.0
@export var probCaramelo: float = 0.75
@export var caramelos: int = 8
@export var tiempoResultado: float = 1.0

@export var escena_objeto_cayendo: PackedScene
@export var textura_caramelo: Texture2D
@export var textura_no_caramelo: Texture2D

var puntaje: int = 0
var perdio: bool = false
var ancho_pantalla: float = 800.0

func _ready() -> void:
	$Instruccion.text = "Atrapá los caramelos y evitá las calaveras"

	$TimerJuego.wait_time = tiempoLimite
	$TimerJuego.one_shot = true
	$TimerJuego.timeout.connect(_cuando_se_acaba_el_tiempo)
	$TimerJuego.start()

	ancho_pantalla = get_viewport_rect().size.x

	_programar_proxima_aparicion()

func _process(_delta: float) -> void:
	if $TimerJuego.time_left > 0:
		$ProgressBar.value = $TimerJuego.time_left / tiempoLimite
	else:
		$ProgressBar.value = 0.0

func _programar_proxima_aparicion() -> void:
	var espera: float = randf_range(tiempo_entre_apariciones_min, tiempo_entre_apariciones_max)
	$TimerCaramelos.wait_time = espera
	$TimerCaramelos.one_shot = true
	if not $TimerCaramelos.timeout.is_connected(_generar_objeto):
		$TimerCaramelos.timeout.connect(_generar_objeto)
	$TimerCaramelos.start()

func _generar_objeto() -> void:
	if perdio:
		return

	var objeto: Area2D = escena_objeto_cayendo.instantiate()
	objeto.position = Vector2(randf_range(50.0, ancho_pantalla - 50.0), -50.0)
	objeto.velocidad_caida = randf_range(velocidad_caida_min, velocidad_caida_max)

	var esCaramelo: bool = randf() < probCaramelo
	objeto.esCaramelo = esCaramelo
	objeto.get_node("Calavera").texture = textura_caramelo if esCaramelo else textura_no_caramelo

	add_child(objeto)
	_programar_proxima_aparicion()

func _on_calabaza_atrapo_objeto(objeto: Node2D) -> void:
	if perdio:
		return

	if objeto.esCaramelo:
		puntaje += 1
		objeto.queue_free()
		if puntaje >= caramelos:
			_ganar()
	else:
		objeto.queue_free()
		_perder()

func _ganar() -> void:
	perdio = true
	$TimerJuego.stop()
	$TimerCaramelos.stop()
	await get_tree().create_timer(tiempoResultado).timeout
	terminar(1.0)

func _perder() -> void:
	perdio = true
	$TimerJuego.stop()
	$TimerCaramelos.stop()
	$Resultado.text = "Perdiste"
	await get_tree().create_timer(tiempoResultado).timeout
	terminar(0.0)

func _cuando_se_acaba_el_tiempo() -> void:
	if perdio:
		return
	perdio = true
	$TimerCaramelos.stop()
	var resultado: float = clamp(float(puntaje) / float(caramelos), 0.0, 1.0)
	$Resultado.text = "Se acabó el tiempo"
	await get_tree().create_timer(tiempoResultado).timeout
	terminar(resultado)

func terminar(resultado: float) -> void:
	termino.emit(resultado)
	queue_free()
