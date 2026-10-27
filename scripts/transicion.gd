extends Node2D

signal transicion_terminada

const ESCENA_JUGADOR := preload("res://escenas/general/jugador.tscn")
const ESCENA_ANIMAL := preload("res://escenas/general/animal.tscn")
const ESCENA_PICKUP := preload("res://escenas/general/pickup_llave.tscn")

@export var duracion: float = 6.0
@export var tiempo_extra_puerta: float = 6.0
@export var chance_animal: float = 0.33
@export var es_glitchedstairs: bool = false
@export var escena_habitacion: PackedScene

var jugador: CharacterBody2D = null
var tiempo_restante: float = 0.0
var terminando: bool = false
var puerta_hover: bool = false
var ultimo_animal: Node2D = null

func mostrar_datos(piso: int, vidas: int, _gano: bool) -> void:
	$NumPiso.text = "Piso: " + str(piso)
	$Vidas.text = "Vidas: " + str(vidas)

func _ready() -> void:
	if has_node("Personaje"):
		$Personaje.hide()

	_crear_jugador()
	_crear_label_llaves()
	_crear_label_timer()
	_conectar_salida()
	_conectar_puerta()

	_spawn_animales_rescatados()

	if randf() < chance_animal:
		_spawn_animales()

	if randf() < gestorPartida.chance_pickup:
		_spawn_pickup()

	tiempo_restante = duracion

func _process(delta: float) -> void:
	if terminando:
		return

	_actualizar_label_llaves()
	_actualizar_label_timer()

	if tiempo_restante > 0.0:
		tiempo_restante -= delta

func _crear_jugador() -> void:
	jugador = ESCENA_JUGADOR.instantiate()
	if has_node("Inicio"):
		jugador.position = $Inicio.position
	add_child(jugador)

func _crear_label_llaves() -> void:
	if has_node("Llaves"):
		return
	var label := Label.new()
	label.name = "Llaves"
	label.position = Vector2(16, 12)
	if $NumPiso.get("theme_override_fonts/font") != null:
		label.add_theme_font_override("font", $NumPiso.get("theme_override_fonts/font"))
	label.add_theme_font_size_override("font_size", 18)
	add_child(label)

func _actualizar_label_llaves() -> void:
	if has_node("Llaves"):
		$Llaves.text = gestorPartida.resumen_inventario()

func _crear_label_timer() -> void:
	if has_node("Timer"):
		return
	var ancho: float = 240.0
	var label := Label.new()
	label.name = "Timer"
	label.size = Vector2(ancho, 50)
	label.position = Vector2(get_viewport_rect().size.x * 0.5 - ancho * 0.5, 12)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if $NumPiso.get("theme_override_fonts/font") != null:
		label.add_theme_font_override("font", $NumPiso.get("theme_override_fonts/font"))
	label.add_theme_font_size_override("font_size", 40)
	add_child(label)

func _actualizar_label_timer() -> void:
	if not has_node("Timer"):
		return
	if gestorPartida.run_iniciada:
		$Timer.show()
		$Timer.text = gestorPartida.tiempo_escape_formateado()
	else:
		$Timer.hide()

func _conectar_salida() -> void:
	if not has_node("Salida"):
		return
	var salida := $Salida as Area2D
	if not salida.body_entered.is_connected(_on_salida_body_entered):
		salida.body_entered.connect(_on_salida_body_entered)

func _conectar_puerta() -> void:
	if not has_node("Puerta"):
		return
	var puerta := $Puerta as Area2D
	puerta.input_pickable = true
	if not puerta.mouse_entered.is_connected(_on_puerta_mouse_entered):
		puerta.mouse_entered.connect(_on_puerta_mouse_entered)
	if not puerta.mouse_exited.is_connected(_on_puerta_mouse_exited):
		puerta.mouse_exited.connect(_on_puerta_mouse_exited)

func _on_puerta_mouse_entered() -> void:
	puerta_hover = true

func _on_puerta_mouse_exited() -> void:
	puerta_hover = false

func _unhandled_input(evento: InputEvent) -> void:
	if terminando or not puerta_hover:
		return
	if not (evento is InputEventMouseButton):
		return
	if evento.button_index != MOUSE_BUTTON_LEFT or not evento.pressed:
		return
	if not gestorPartida.usar_llave():
		return
	_entrar_a_habitacion()

func _spawn_animales() -> void:
	var nombres: Array[String] = gestorPartida.elegir_animales(es_glitchedstairs)
	var base: Vector2 = $SpawnAnimal.position if has_node("SpawnAnimal") else Vector2(450, 300)
	var desplazamiento: int = 0
	for nombre in nombres:
		var ruta: String = gestorPartida.textura_animal(nombre)
		if not ResourceLoader.exists(ruta):
			continue
		var animal := ESCENA_ANIMAL.instantiate()
		animal.nombre = nombre
		animal.textura = load(ruta)
		animal.position = base + Vector2(desplazamiento * 70, 0)
		animal.rescatado.connect(_on_animal_rescatado)
		add_child(animal)
		desplazamiento += 1

func _spawn_animales_rescatados() -> void:
	var inicio: Vector2 = jugador.position if jugador != null else Vector2(450, 300)
	var desplazamiento: int = 1
	for nombre in gestorPartida.animales_rescatados:
		var ruta: String = gestorPartida.textura_animal(nombre)
		if not ResourceLoader.exists(ruta):
			continue
		var animal := ESCENA_ANIMAL.instantiate()
		animal.nombre = nombre
		animal.textura = load(ruta)
		animal.objetivo = ultimo_animal if ultimo_animal != null else jugador
		animal.fue_rescatado = true
		animal.position = inicio - Vector2(desplazamiento * 70, 0)
		add_child(animal)
		ultimo_animal = animal
		desplazamiento += 1

func _spawn_pickup() -> void:
	var p := ESCENA_PICKUP.instantiate()
	var lugares: Array[Vector2] = []
	if has_node("SpawnPickup"):
		lugares.append($SpawnPickup.position)
	if has_node("SpawnAnimal"):
		lugares.append($SpawnAnimal.position)
	if lugares.is_empty():
		var tam: Vector2 = get_viewport_rect().size
		lugares.append(Vector2(tam.x * 0.5, tam.y * 0.4))
	p.position = lugares[randi() % lugares.size()]
	add_child(p)

func _on_animal_rescatado(animal: Node2D) -> void:
	gestorPartida.rescatar_animal(animal.nombre)
	animal.objetivo = ultimo_animal if ultimo_animal != null else jugador
	ultimo_animal = animal

func _entrar_a_habitacion() -> void:
	tiempo_restante += tiempo_extra_puerta

	if has_node("Puerta"):
		$Puerta.queue_free()

	if escena_habitacion == null:
		return

	var habitacion: Node = escena_habitacion.instantiate()
	add_child(habitacion)

func _on_salida_body_entered(body: Node2D) -> void:
	if body != jugador:
		return
	_terminar()

func _terminar() -> void:
	if terminando:
		return
	terminando = true
	transicion_terminada.emit()
	queue_free()
