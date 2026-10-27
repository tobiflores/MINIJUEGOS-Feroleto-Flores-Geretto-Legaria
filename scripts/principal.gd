extends Node2D

const DISTANCIA_INTERACCION: float = 112.0

@export var pisos: Array[PisoMinijuegos] = []
@export var texturaVecino: Texture2D

@onready var jugador: CharacterBody2D = $Jugador
@onready var etiqueta_piso: Label = $Interfaz/EtiquetaPiso
@onready var etiqueta_vidas: Label = $Interfaz/EtiquetaVidas
@onready var etiqueta_interaccion: Label = $Interfaz/EtiquetaInteraccion
@onready var etiqueta_estado: Label = $Interfaz/EtiquetaEstado

var indice_piso_actual: int = 0
var departamentos_resueltos: Array[bool] = []
var posiciones_vecinos: Array[Vector2] = []
var vecinos: Array[Sprite2D] = []
var vecino_cercano: int = -1
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
	for _departamento in pisos[indice_piso_actual].departamentos:
		departamentos_resueltos.append(false)

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
		add_child(vecino)

		var etiqueta := Label.new()
		etiqueta.text = departamentos[indice].habitante
		etiqueta.position = Vector2(-100, -120)
		etiqueta.size = Vector2(200, 30)
		etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		etiqueta.add_theme_color_override("font_color", Color("#fff0c9"))
		etiqueta.add_theme_font_size_override("font_size", 18)
		vecino.add_child(etiqueta)
		vecinos.append(vecino)

func _actualizar_hud() -> void:
	etiqueta_piso.text = "PISO %d" % gestorPartida.pisoActual
	etiqueta_vidas.text = "VIDAS  %d" % gestorPartida.vidas

func _process(_delta: float) -> void:
	if minijuego_activo or partida_terminada:
		return

	var nuevo_vecino: int = -1
	var distancia_menor: float = DISTANCIA_INTERACCION
	for indice in posiciones_vecinos.size():
		if departamentos_resueltos[indice]:
			continue
		var distancia: float = jugador.global_position.distance_to(posiciones_vecinos[indice])
		if distancia < distancia_menor:
			distancia_menor = distancia
			nuevo_vecino = indice

	vecino_cercano = nuevo_vecino
	etiqueta_interaccion.visible = vecino_cercano >= 0

func _unhandled_input(evento: InputEvent) -> void:
	if minijuego_activo or partida_terminada or vecino_cercano < 0:
		return
	if evento is InputEventKey and evento.pressed and not evento.echo:
		if evento.keycode == KEY_E or evento.physical_keycode == KEY_E:
			_entrar_al_departamento(vecino_cercano)
			get_viewport().set_input_as_handled()

func _entrar_al_departamento(indice: int) -> void:
	var departamento: DepartamentoMinijuego = pisos[indice_piso_actual].departamentos[indice]
	var minijuego: Node = departamento.escena_minijuego.instantiate()
	if not minijuego.has_signal("termino"):
		push_error("El minijuego del departamento debe emitir la señal termino.")
		minijuego.queue_free()
		return

	minijuego_activo = true
	vecino_cercano = -1
	jugador.velocity = Vector2.ZERO
	jugador.hide()
	jugador.set_physics_process(false)
	etiqueta_interaccion.hide()
	minijuego.connect("termino", _cuando_termina_minijuego.bind(indice))
	add_child(minijuego)

func _cuando_termina_minijuego(resultado: float, indice: int) -> void:
	var gano: bool = resultado >= 1.0
	if gano:
		departamentos_resueltos[indice] = true
		vecinos[indice].modulate = Color(0.6, 1.0, 0.6)

	var piso_completo: bool = gano and not departamentos_resueltos.has(false)
	var hay_otro_piso: bool = piso_completo and indice_piso_actual + 1 < pisos.size()
	await gestorPartida.resultado(resultado, piso_completo, hay_otro_piso)
	minijuego_activo = false
	_actualizar_hud()

	if gestorPartida.vidas <= 0:
		partida_terminada = true
		etiqueta_estado.text = "SIN VIDAS"
		etiqueta_estado.show()
		return

	if hay_otro_piso:
		indice_piso_actual += 1
		_inicializar_departamentos()
		_crear_vecinos()
	elif piso_completo:
		partida_terminada = true
		etiqueta_estado.text = "TODOS LOS VECINOS AYUDADOS"
		etiqueta_estado.show()

	jugador.show()
	jugador.set_physics_process(true)
