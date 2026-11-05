extends Node2D

const PUERTA_DIRECTA_ANCHO: float = 146.0
const PUERTA_DIRECTA_Y_MAX: float = 380.0

@export var pisos: Array[PisoMinijuegos] = []
@export var texturaVecino: Texture2D

@onready var jugador: CharacterBody2D = $Jugador
@onready var etiqueta_piso: Label = $Interfaz/EtiquetaPiso
@onready var etiqueta_vidas: Label = $Interfaz/EtiquetaVidas
@onready var etiqueta_interaccion: Label = $Interfaz/EtiquetaInteraccion
@onready var etiqueta_estado: Label = $Interfaz/EtiquetaEstado

const NOMBRES_NUEVOS: Array[String] = ["Marta", "Bruno", "Sofia", "Lucas", "Camila", "Diego", "Julia", "Mateo", "Paula", "Hugo", "Elena", "Pablo"]

var indice_piso_actual: int = 0
var vuelta_pisos: int = 0
var nombres_disponibles: Array[String] = []
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

		var etiqueta := Label.new()
		etiqueta.text = departamentos[indice].habitante if vuelta_pisos == 0 else _nombre_nuevo()
		etiqueta.position = Vector2(-100, -120)
		etiqueta.size = Vector2(200, 30)
		etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		etiqueta.add_theme_color_override("font_color", Color("#fff0c9"))
		etiqueta.add_theme_font_size_override("font_size", 18)
		vecino.add_child(etiqueta)
		vecinos.append(vecino)

func _nombre_nuevo() -> String:
	if nombres_disponibles.is_empty():
		nombres_disponibles.assign(NOMBRES_NUEVOS)
		nombres_disponibles.shuffle()
	return nombres_disponibles.pop_back()

func _actualizar_hud() -> void:
	etiqueta_piso.text = "PISO %d" % gestorPartida.pisoActual
	etiqueta_vidas.text = "VIDAS  %d" % gestorPartida.vidas

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
	etiqueta_interaccion.hide()
	minijuego.connect("termino", _cuando_termina_minijuego.bind(indice))
	add_child(minijuego)

func _cuando_termina_minijuego(resultado: float, indice: int) -> void:
	var gano: bool = resultado >= 1.0
	departamentos_intentados[indice] = true
	if gano:
		departamentos_resueltos[indice] = true
		vecinos[indice].modulate = Color(0.6, 1.0, 0.6)

	var piso_completo: bool = gano and not departamentos_resueltos.has(false)
	var hay_otro_piso: bool = piso_completo
	var todos_intentados: bool = not departamentos_intentados.has(false)

	await gestorPartida.resultado(resultado, piso_completo, todos_intentados)
	minijuego_activo = false
	_actualizar_hud()

	if gestorPartida.vidas <= 0:
		partida_terminada = true
		etiqueta_estado.text = "SIN VIDAS"
		etiqueta_estado.show()
		return

	if hay_otro_piso:
		indice_piso_actual += 1
		if indice_piso_actual >= pisos.size():
			indice_piso_actual = 0
			vuelta_pisos += 1
		_inicializar_departamentos()
		_crear_vecinos()
	elif todos_intentados:
		for i in departamentos_intentados.size():
			departamentos_intentados[i] = false

	if indice < posiciones_vecinos.size():
		jugador.position = Vector2(posiciones_vecinos[indice].x, 565)
	jugador.show()
	jugador.set_physics_process(true)
