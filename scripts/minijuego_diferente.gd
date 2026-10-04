extends Node2D

signal termino(resultado: float)

@export var tiempoLimite: float = 6.0
@export var tiempoMostrarResultado: float = 1.0

@export var texturaNormal: Texture2D
@export var texturaDiferente: Texture2D
@export var texturaCursor: Texture2D

var personajes: Array[Button] = []
var personajeDiferente: Button
var puedeClickear: bool = false

func _ready() -> void:
	Input.set_custom_mouse_cursor(texturaCursor)
	personajes = [$GridContainer/PJ1, $GridContainer/PJ2, $GridContainer/PJ3, $GridContainer/PJ4, $GridContainer/PJ5, $GridContainer/PJ6, $GridContainer/PJ7, $GridContainer/PJ8, $GridContainer/PJ9]

	personajeDiferente = personajes[randi() % personajes.size()]

	for personaje in personajes:
		personaje.icon = texturaDiferente if personaje == personajeDiferente else texturaNormal
		personaje.pressed.connect(_al_elegir_personaje.bind(personaje))

	$Instruccion.text = "Clickea a la distinta!"

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

func _al_elegir_personaje(personaje_elegido: Button) -> void:
	if not puedeClickear:
		return
	puedeClickear = false
	$Timer.stop()

	for personaje in personajes:
		personaje.disabled = true

	var resultado: float

	if personaje_elegido == personajeDiferente:
		resultado = 1.0
		$Mensaje.text = "¡Ganaste!"
	else:
		resultado = 0.0
		$Mensaje.text = ""

	await get_tree().create_timer(tiempoMostrarResultado).timeout
	terminar(resultado)

func _cuando_se_acaba_el_tiempo() -> void:
	for personaje in personajes:
		personaje.disabled = true
	$Mensaje.text = ""
	await get_tree().create_timer(tiempoMostrarResultado).timeout
	terminar(0.0)

func terminar(resultado: float) -> void:
	Input.set_custom_mouse_cursor(null)
	termino.emit(resultado)
	queue_free()
