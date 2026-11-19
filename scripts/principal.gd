extends Node2D

const PUERTA_DIRECTA_ANCHO: float = 146.0
const PUERTA_DIRECTA_Y_MAX: float = 340.0
const ESCENA_MUERTE: String = "res://escenas/general/pantalla_muerte.tscn"
const ESCENA_AFUERAS: String = "res://escenas/general/afueras.tscn"

@export var pisos: Array[PisoMinijuegos] = []

@onready var jugador: CharacterBody2D = $Jugador
@onready var etiqueta_piso: Label = $Interfaz/EtiquetaPiso
@onready var vidas_hud: HBoxContainer = $Interfaz/VidasHud
@onready var feedback: CanvasLayer = $Feedback

var indice_piso_actual: int = 0
var departamentos_intentados: Array[bool] = []
var posiciones_puertas: Array[Vector2] = []
var minijuego_activo: bool = false
var partida_terminada: bool = false

func _ready() -> void:
	if pisos.is_empty():
		push_error("Principal necesita al menos un piso configurado.")
		return
	for piso in pisos:
		if piso == null or piso.departamentos.is_empty():
			push_error("Cada piso debe tener al menos un departamento.")
			return
		for departamento in piso.departamentos:
			if departamento == null or departamento.escena_minijuego == null:
				push_error("Cada departamento debe tener un minijuego asignado.")
				return

	gestorPartida.configurar_pisos(pisos.size())
	gestorPartida.iniciar_run()
	_inicializar_departamentos()
	_calcular_puertas()
	_actualizar_hud()

func _inicializar_departamentos() -> void:
	departamentos_intentados.clear()
	for _departamento in pisos[indice_piso_actual].departamentos:
		departamentos_intentados.append(false)

func _calcular_puertas() -> void:
	posiciones_puertas.clear()
	var tamano: Vector2 = get_viewport_rect().size
	var cantidad: int = pisos[indice_piso_actual].departamentos.size()
	for indice in cantidad:
		var x: float = tamano.x * float(indice + 1) / float(cantidad + 1)
		posiciones_puertas.append(Vector2(x, tamano.y * 0.69))

func _actualizar_hud() -> void:
	etiqueta_piso.text = "PISO %d" % gestorPartida.pisoActual
	vidas_hud.actualizar(gestorPartida.vidas)

func _unhandled_input(event: InputEvent) -> void:
	if minijuego_activo or partida_terminada:
		return
	if not event.is_action_pressed("interactuar"):
		return

	for indice in posiciones_puertas.size():
		if departamentos_intentados[indice]:
			continue
		var en_puerta: bool = absf(jugador.global_position.x - posiciones_puertas[indice].x) < PUERTA_DIRECTA_ANCHO * 0.5 \
				and jugador.global_position.y < PUERTA_DIRECTA_Y_MAX
		if en_puerta:
			get_viewport().set_input_as_handled()
			_entrar_al_departamento(indice)
			break

func _entrar_al_departamento(indice: int) -> void:
	var departamento: DepartamentoMinijuego = pisos[indice_piso_actual].departamentos[indice]
	var minijuego: Node = departamento.escena_minijuego.instantiate()
	if not minijuego.has_signal("termino"):
		push_error("El minijuego del departamento debe emitir la señal termino.")
		minijuego.queue_free()
		return

	minijuego_activo = true
	jugador.velocity = Vector2.ZERO
	jugador.hide()
	jugador.set_physics_process(false)
	$Jugador/CollisionShape2D.set_deferred("disabled", true)
	$BarreraPared/CollisionShape2D.set_deferred("disabled", true)
	minijuego.connect("termino", _cuando_termina_minijuego.bind(indice, minijuego))
	add_child(minijuego)

func _cuando_termina_minijuego(resultado: float, indice: int, minijuego: Node) -> void:
	var gano: bool = resultado >= 1.0
	departamentos_intentados[indice] = true

	var todos_intentados: bool = not departamentos_intentados.has(false)
	var piso_completo: bool = todos_intentados
	var hay_otro_piso: bool = piso_completo

	if gano:
		await feedback.mostrar(true, "¡MUY BIEN!")
	else:
		vidas_hud.actualizar(gestorPartida.vidas - 1)
		await feedback.mostrar(false, "FALLIDO")

	if is_instance_valid(minijuego):
		minijuego.queue_free()

	await gestorPartida.resultado(resultado, piso_completo, todos_intentados)
	minijuego_activo = false
	_actualizar_hud()

	if gestorPartida.vidas <= 0:
		partida_terminada = true
		get_tree().change_scene_to_file.call_deferred(ESCENA_MUERTE)
		return

	if hay_otro_piso:
		indice_piso_actual += 1
		if indice_piso_actual >= pisos.size():
			partida_terminada = true
			get_tree().change_scene_to_file.call_deferred(ESCENA_AFUERAS)
			return
		_inicializar_departamentos()
		_calcular_puertas()
		_actualizar_hud()

	if indice < posiciones_puertas.size():
		jugador.position = Vector2(posiciones_puertas[indice].x, 565)
	jugador.show()
	jugador.set_physics_process(true)
	$Jugador/CollisionShape2D.set_deferred("disabled", false)
	$BarreraPared/CollisionShape2D.set_deferred("disabled", false)
