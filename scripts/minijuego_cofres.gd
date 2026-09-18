extends Node2D

signal termino(resultado: float)

@export var tiempo_limite: float = 6.0
@export var tiempo_mostrar_premio: float = 1.2
@export var tiempo_mostrar_resultado: float = 1.0
@export var cantidad_intercambios: int = 4
@export var tiempo_por_intercambio: float = 0.35

@export var textura_cerrado: Texture2D
@export var textura_abierto_vacio: Texture2D
@export var textura_abierto_premio: Texture2D

var cofres: Array[Button] = []
var cofre_premiado: Button
var puede_clickear: bool = false

func _ready() -> void:
	cofres = [$Cofre1, $Cofre2, $Cofre3]
	cofre_premiado = cofres[randi() % cofres.size()]

	for cofre in cofres:
		cofre.disabled = true
		cofre.icon = textura_abierto_premio if cofre == cofre_premiado else textura_abierto_vacio
		cofre.pressed.connect(_al_elegir_cofre.bind(cofre))

	$Timer.wait_time = tiempo_limite
	$Timer.one_shot = true
	$Timer.timeout.connect(_cuando_se_acaba_el_tiempo)
	$Timer.start()

	await get_tree().create_timer(tiempo_mostrar_premio).timeout

	for cofre in cofres:
		cofre.icon = textura_cerrado

	await mezclar()

	for cofre in cofres:
		cofre.disabled = false
	puede_clickear = true

func mezclar() -> void:
	for i in cantidad_intercambios:
		var a: Button = cofres[randi() % cofres.size()]
		var b: Button = cofres[randi() % cofres.size()]
		while b == a:
			b = cofres[randi() % cofres.size()]

		var pos_a: Vector2 = a.position
		var pos_b: Vector2 = b.position

		var tween := create_tween().set_parallel(true)
		tween.tween_property(a, "position", pos_b, tiempo_por_intercambio)
		tween.tween_property(b, "position", pos_a, tiempo_por_intercambio)
		await tween.finished

func _al_elegir_cofre(cofre_elegido: Button) -> void:
	if not puede_clickear:
		return
	puede_clickear = false
	$Timer.stop()

	for cofre in cofres:
		cofre.disabled = true

	cofre_premiado.icon = textura_abierto_premio

	if cofre_elegido == cofre_premiado:
		$Mensaje.text = "Ganaste"
		await get_tree().create_timer(tiempo_mostrar_resultado).timeout
		terminar(1.0)
	else:
		cofre_elegido.icon = textura_abierto_vacio
		$Mensaje.text = "Cofre vacío"
		await get_tree().create_timer(tiempo_mostrar_resultado).timeout
		terminar(0.0)

func _cuando_se_acaba_el_tiempo() -> void:
	for cofre in cofres:
		cofre.disabled = true
	cofre_premiado.icon = textura_abierto_premio
	$Mensaje.text = "Tiempo acabado"
	await get_tree().create_timer(tiempo_mostrar_resultado).timeout
	terminar(0.0)

func terminar(resultado: float) -> void:
	termino.emit(resultado)
	queue_free()
