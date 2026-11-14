extends Node2D

const PUERTA_DIRECTA_ANCHO: float = 146.0
const PUERTA_DIRECTA_Y_MAX: float = 380.0
const ESCENA_MUERTE: String = "res://escenas/general/pantalla_muerte.tscn"

@export var pisos: Array[PisoMinijuegos] = []
@export var texturaVecino: Texture2D

@onready var jugador: CharacterBody2D = $Jugador
@onready var etiqueta_piso: Label = $Interfaz/EtiquetaPiso
@onready var vidas_hud: HBoxContainer = $Interfaz/VidasHud
@onready var feedback: CanvasLayer = $Feedback
@onready var etiqueta_interaccion: Label = $Interfaz/EtiquetaInteraccion
@onready var etiqueta_estado: Label = $Interfaz/EtiquetaEstado

var indice_piso_actual: int = 0
var departamentos_resueltos: Array[bool] = []
var departamentos_intentados: Array[bool] = []
var posiciones_vecinos: Array[Vector2] = []
var vecinos: Array[Sprite2D] = []
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

	etiqueta_interaccion.hide()
	etiqueta_estado.hide()
	gestorPartida.configurar_pisos(pisos.size())
	gestorPartida.iniciar_run()
	_inicializar_departamentos()
	_crear_vecinos()
	_actualizar_hud()

func _inicializar_departamentos() -> void:
	departamentos_resueltos.clear()
	departamentos_intentados.clear()
	for _departamento in pisos[indice_piso_actual].departamentos:
		departamentos_resueltos.append(false)
		departamentos_intentados.append(false)

func _crear_vecinos() -> void:
	for vecino in vecinos:
		vecino.queue_free()
	vecinos.clear()
	posiciones_vecinos.clear()

	var tamano: Vector2 = get_viewport_rect().size
	var departamentos: Array[DepartamentoMinijuego] = pisos[indice_piso_actual].departamentos
	for indice in departamentos.size():
		var x: float = tamano.x * float(indice + 1) / float(departamentos.size() + 1)
		var posicion := Vector2(x, tamano.y * 0.69)
		posiciones_vecinos.append(posicion)

		var vecino := Sprite2D.new()
		vecino.texture = texturaVecino
		vecino.position = posicion
		vecino.scale = Vector2(0.28, 0.28)
		vecino.visible = false
		add_child(vecino)
		vecinos.append(vecino)

func _actualizar_hud() -> void:
	etiqueta_piso.text = "PISO %d" % gestorPartida.pisoActual
	vidas_hud.actualizar(gestorPartida.vidas)

func _process(_delta: float) -> void:
	if minijuego_activo or partida_terminada:
		return

	for indice in posiciones_vecinos.size():
		if departamentos_intentados[indice]:
			continue
		var en_puerta: bool = absf(jugador.global_position.x - posiciones_vecinos[indice].x) < PUERTA_DIRECTA_ANCHO * 0.5 \
				and jugador.global_position.y < PUERTA_DIRECTA_Y_MAX
		if en_puerta:
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
	etiqueta_interaccion.hide()
	minijuego.connect("termino", _cuando_termina_minijuego.bind(indice, minijuego))
	add_child(minijuego)

func _cuando_termina_minijuego(resultado: float, indice: int, minijuego: Node) -> void:
	var gano: bool = resultado >= 1.0
	departamentos_intentados[indice] = true
	if gano:
		departamentos_resueltos[indice] = true
		vecinos[indice].modulate = Color(0.6, 1.0, 0.6)

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
			indice_piso_actual = 0
			gestorPartida.configurar_pisos(pisos.size())
		_inicializar_departamentos()
		_crear_vecinos()
		_actualizar_hud()

	if indice < posiciones_vecinos.size():
		jugador.position = Vector2(posiciones_vecinos[indice].x, 565)
	jugador.show()
	jugador.set_physics_process(true)
	$Jugador/CollisionShape2D.set_deferred("disabled", false)
