extends Node2D

signal termino(resultado: float)

@export var tiempoLimite: float = 15.0
@export var tiempoMostrarInicio: float = 1.5
@export var tiempoVoltear: float = 0.6
@export var tiempoMostrarResultado: float = 1.0

@export var texturaDorso: Texture2D
@export var texturasFrente: Array[Texture2D]

var cartas: Array[Button] = []
var valores: Array[int] = []
var encontradas: Array[Button] = []
var primeraCarta: Button = null
var puedeClickear: bool = false
var terminado: bool = false

func _ready() -> void:
	cartas = [$GridContainer/Carta1, $GridContainer/Carta2, $GridContainer/Carta3, $GridContainer/Carta4, $GridContainer/Carta5, $GridContainer/Carta6, $GridContainer/Carta7, $GridContainer/Carta8]

	var totalParejas: int = int(cartas.size() / 2.0)
	for i in totalParejas:
		valores.append(i)
		valores.append(i)
	valores.shuffle()

	for i in cartas.size():
		cartas[i].icon = texturasFrente[valores[i]]
		cartas[i].pressed.connect(_al_elegir_carta.bind(cartas[i]))

	$ProgressBar.min_value = 0.0
	$ProgressBar.max_value = 1.0
	$ProgressBar.value = 1.0
	$Instruccion.text = "Memorizá las cartas"

	await get_tree().create_timer(tiempoMostrarInicio).timeout

	for carta in cartas:
		carta.icon = texturaDorso
	$Instruccion.text = "Encontrá las parejas"

	$Timer.wait_time = tiempoLimite
	$Timer.one_shot = true
	$Timer.timeout.connect(_cuando_se_acaba_el_tiempo)
	$Timer.start()

	puedeClickear = true

func _process(_delta: float) -> void:
	if not $Timer.is_stopped():
		$ProgressBar.value = $Timer.time_left / tiempoLimite

func _al_elegir_carta(carta: Button) -> void:
	if not puedeClickear:
		return
	if carta in encontradas or carta == primeraCarta:
		return

	carta.icon = texturasFrente[valores[cartas.find(carta)]]

	if primeraCarta == null:
		primeraCarta = carta
		return

	puedeClickear = false
	var segundaCarta: Button = carta

	if valores[cartas.find(primeraCarta)] == valores[cartas.find(segundaCarta)]:
		encontradas.append(primeraCarta)
		encontradas.append(segundaCarta)
		primeraCarta = null
		if encontradas.size() == cartas.size():
			_ganar()
		else:
			puedeClickear = true
	else:
		await get_tree().create_timer(tiempoVoltear).timeout
		if terminado:
			return
		primeraCarta.icon = texturaDorso
		segundaCarta.icon = texturaDorso
		primeraCarta = null
		puedeClickear = true

func _ganar() -> void:
	terminado = true
	$Timer.stop()
	$Mensaje.text = "¡Bien!"
	await get_tree().create_timer(tiempoMostrarResultado).timeout
	terminar(1.0)

func _cuando_se_acaba_el_tiempo() -> void:
	if terminado:
		return
	terminado = true
	puedeClickear = false
	$ProgressBar.value = 0.0
	var resultado: float = float(encontradas.size()) / float(cartas.size())
	$Mensaje.text = ""
	await get_tree().create_timer(tiempoMostrarResultado).timeout
	terminar(resultado)

func terminar(resultado: float) -> void:
	termino.emit(resultado)
	queue_free()
