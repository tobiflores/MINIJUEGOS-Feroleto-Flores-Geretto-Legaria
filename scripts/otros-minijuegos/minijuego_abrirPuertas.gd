extends Node2D

signal termino(resultado: float)

@export var tiempoLimite: float = 6.0
@export var tiempoMostrarResultado: float = 1.0

@export var texturaCerrada: Texture2D
@export var texturaAbierta: Texture2D
@export var texturaCursor: Texture2D

var puertas: Array[Button] = []
var puertasAbiertas: int = 0
var puedeClickear: bool = false

func _ready() -> void:
	Input.set_custom_mouse_cursor(texturaCursor)
	puertas = [$GridContainer/PJ1, $GridContainer/PJ2, $GridContainer/PJ3, $GridContainer/PJ4, $GridContainer/PJ5, $GridContainer/PJ6, $GridContainer/PJ7, $GridContainer/PJ8, $GridContainer/PJ9]

	for puerta in puertas:
		puerta.icon = texturaCerrada
		puerta.pressed.connect(_al_elegir_puerta.bind(puerta))

	$Instruccion.text = "¡Abrí todas las puertas!"

	$Timer.wait_time = tiempoLimite
	$Timer.one_shot = true
	$Timer.timeout.connect(_cuando_se_acaba_el_tiempo)
	$Timer.start()

	puedeClickear = true

func _process(_delta: float) -> void:
	if $Timer.time_left > 0:
		$ProgressBar.value = $Timer.time_left / tiempoLimite
	else:
		$ProgressBar.value = 0.0

func _al_elegir_puerta(puerta_elegida: Button) -> void:
	if not puedeClickear:
		return

	if puerta_elegida.icon == texturaAbierta:
		return

	puerta_elegida.icon = texturaAbierta
	puertasAbiertas += 1

	if puertasAbiertas >= puertas.size():
		_ganar()

func _ganar() -> void:
	puedeClickear = false
	$Timer.stop()

	for puerta in puertas:
		puerta.disabled = true

	$Mensaje.text = "¡Bien!"
	await get_tree().create_timer(tiempoMostrarResultado).timeout
	terminar(1.0)

func _cuando_se_acaba_el_tiempo() -> void:
	puedeClickear = false

	for puerta in puertas:
		puerta.disabled = true

	var resultado: float = clamp(float(puertasAbiertas) / float(puertas.size()), 0.0, 1.0)
	$Mensaje.text = ""
	await get_tree().create_timer(tiempoMostrarResultado).timeout
	terminar(resultado)

func terminar(resultado: float) -> void:
	Input.set_custom_mouse_cursor(null)
	termino.emit(resultado)
	queue_free()
