extends Node

signal tiempo_agotado

const PENALIZACION_POR_ANIMAL: float = 20.0
const CHANCE_PICKUP_BASE: float = 0.08
const TIEMPO_ESCAPE_INICIAL: float = 300.0

const VARIANTES: Array[Dictionary] = [
	{"escena": "res://escenas/general/transicion.tscn", "peso": 46.5},
	{"escena": "res://escenas/general/transicion_stairsdownwards.tscn", "peso": 46.5},
	{"escena": "res://escenas/general/transicion_stairshalfawypoint.tscn", "peso": 7.0},
	{"escena": "res://escenas/general/transicion_dogvariant.tscn", "peso": 20.0, "requiere_item": "collar_perro"},
	{"escena": "res://escenas/general/transicion_glitched.tscn", "peso": 20.0, "min_glitchedquest": 3},
]

const ITEMS_INFO: Dictionary = {
	"atun": {
		"textura": "res://imagenes/AtúnItem.png",
		"desc": "Aumenta un 20% la chance de encontrar gatos y reduce un 20% la de otros animales.",
	},
	"alivemouse": {
		"textura": "res://imagenes/alivemouse.png",
		"desc": "Cuenta como un animal e incrementa un 8% la chance de agarrar un pickup.",
	},
	"deadmouse": {
		"textura": "res://imagenes/deadmouse.png",
		"desc": "Incrementa las chances de encontrar un gato adicional.",
	},
	"glitchedmouse": {
		"textura": "res://imagenes/glitchedmouse.gif",
		"desc": "???",
	},
}

var pisoActual: int = 20
var vidas: int = 3
var glitchedquest: int = 0
var tiene_atun: bool = false
var chance_pickup: float = CHANCE_PICKUP_BASE
var gato_extra_chance: float = 0.0
var tiempo_escape: float = TIEMPO_ESCAPE_INICIAL
var run_iniciada: bool = false
var transicion_actual: Node = null

var inventario: Dictionary = {
	"llaves": 0,
	"items": [],
	"animales": [],
}

var llaves: int:
	get:
		return inventario["llaves"]
	set(valor):
		inventario["llaves"] = valor

var items: Array:
	get:
		return inventario["items"]

var animales_rescatados: Array:
	get:
		return inventario["animales"]

func resumen_inventario() -> String:
	var partes: Array[String] = []
	partes.append("Llaves: " + str(inventario["llaves"]))
	if not inventario["items"].is_empty():
		partes.append("Items: " + ", ".join(inventario["items"]))
	if not inventario["animales"].is_empty():
		partes.append("Animales: " + ", ".join(inventario["animales"]))
	return "\n".join(partes)

func _process(delta: float) -> void:
	if not run_iniciada:
		return
	if tiempo_escape <= 0.0:
		return

	tiempo_escape -= delta
	if tiempo_escape <= 0.0:
		tiempo_escape = 0.0
		tiempo_agotado.emit()

func iniciar_run() -> void:
	if run_iniciada:
		return
	run_iniciada = true
	tiempo_escape = TIEMPO_ESCAPE_INICIAL
	inventario = {
		"llaves": 1,
		"items": [],
		"animales": [],
	}

func tiempo_escape_formateado() -> String:
	var total: int = int(ceil(tiempo_escape))
	var minutos: int = total / 60
	var segundos: int = total % 60
	return "%d:%02d" % [minutos, segundos]

func penalizacion_velocidad() -> float:
	return PENALIZACION_POR_ANIMAL * float(animales_rescatados.size())

func rescatar_animal(nombre: String) -> void:
	if nombre not in inventario["animales"]:
		inventario["animales"].append(nombre)

func tiene_item(nombre: String) -> bool:
	return nombre in inventario["items"]

func agregar_item(nombre: String) -> void:
	if nombre not in inventario["items"]:
		inventario["items"].append(nombre)

func agarrar_llave() -> void:
	inventario["llaves"] += 1

func usar_llave() -> bool:
	if inventario["llaves"] <= 0:
		return false
	inventario["llaves"] -= 1
	return true

func info_item(nombre: String) -> Dictionary:
	return ITEMS_INFO.get(nombre, {})

func aplicar_efecto_item(nombre: String) -> void:
	agregar_item(nombre)
	match nombre:
		"atun":
			tiene_atun = true
		"alivemouse":
			chance_pickup += 0.08
			rescatar_animal("alivemouse")
		"deadmouse":
			gato_extra_chance = 0.5
		"glitchedmouse":
			glitchedquest += 1

func elegir_item_habitacion() -> String:
	if glitchedquest > 1:
		return "glitchedmouse"

	var pool: Array[String] = []
	for nombre in ["atun", "alivemouse", "deadmouse"]:
		if nombre not in items:
			pool.append(nombre)

	if pool.is_empty():
		return ""
	return pool[randi() % pool.size()]

func elegir_animales(es_glitchedstairs: bool) -> Array[String]:
	var resultado: Array[String] = []

	var principal: String = _sortear_animal(es_glitchedstairs)
	if principal != "":
		resultado.append(principal)

	if gato_extra_chance > 0.0 and randf() < gato_extra_chance:
		resultado.append("gato")

	return resultado

func _sortear_animal(es_glitchedstairs: bool) -> String:
	var candidatos: Array[Dictionary] = [
		{"nombre": "gato", "textura": "res://imagenes/cat.png", "peso": 10.0, "es_gato": true},
		{"nombre": "perro", "textura": "res://imagenes/dog.png", "peso": 10.0},
		{"nombre": "conejo", "textura": "res://imagenes/bun.png", "peso": 10.0},
		{"nombre": "gato_gordo", "textura": "res://imagenes/fatcoolcat.png", "peso": float(randi_range(1, 10)), "es_gato": true},
		{"nombre": "conejo_cool", "textura": "res://imagenes/coolbun.png", "peso": float(randi_range(1, 10))},
		{"nombre": "officecats", "textura": "res://imagenes/officecats.gif", "peso": float(randi_range(1, 10)), "es_gato": true},
	]

	if es_glitchedstairs and glitchedquest > 3:
		candidatos.append({"nombre": "amigo", "textura": "res://imagenes/FRIEND.png", "peso": 10.0})

	var total: float = 0.0
	var validos: Array[Dictionary] = []
	for c in candidatos:
		if not ResourceLoader.exists(c["textura"]):
			continue
		if c["nombre"] in animales_rescatados:
			continue
		var peso: float = c["peso"]
		if tiene_atun:
			peso *= (1.2 if c.get("es_gato", false) else 0.8)
		if peso <= 0.0:
			continue
		c["peso"] = peso
		validos.append(c)
		total += peso

	if validos.is_empty():
		return ""

	var tirada: float = randf() * total
	for c in validos:
		tirada -= c["peso"]
		if tirada <= 0.0:
			return c["nombre"]
	return validos[0]["nombre"]

func textura_animal(nombre: String) -> String:
	match nombre:
		"gato": return "res://imagenes/cat.png"
		"perro": return "res://imagenes/dog.png"
		"conejo": return "res://imagenes/bun.png"
		"gato_gordo": return "res://imagenes/fatcoolcat.png"
		"conejo_cool": return "res://imagenes/coolbun.png"
		"officecats": return "res://imagenes/officecats.gif"
		"amigo": return "res://imagenes/FRIEND.png"
	return ""

func _elegir_variante() -> String:
	var disponibles: Array[Dictionary] = []
	var total: float = 0.0

	for v in VARIANTES:
		var item: String = v.get("requiere_item", "")
		if item != "" and not tiene_item(item):
			continue
		if glitchedquest < int(v.get("min_glitchedquest", 0)):
			continue
		disponibles.append(v)
		total += float(v.get("peso", 0.0))

	var tirada: float = randf() * total
	for v in disponibles:
		tirada -= float(v.get("peso", 0.0))
		if tirada <= 0.0:
			return v["escena"]

	return disponibles[0]["escena"]

func configurar_pisos(cantidad: int) -> void:
	pisoActual = cantidad

func resultado(
	resultado_minijuego: float,
	piso_completo: bool = false,
	mostrar_transicion_despues: bool = true
) -> void:
	var gano: bool = resultado_minijuego >= 1.0

	if gano and piso_completo:
		pisoActual -= 1
	elif not gano:
		vidas -= 1

	if mostrar_transicion_despues:
		await mostrar_transicion(gano)

func mostrar_transicion(gano: bool) -> void:
	if transicion_actual != null and is_instance_valid(transicion_actual):
		await transicion_actual.transicion_terminada
		return
	iniciar_run()
	var escena: PackedScene = load(_elegir_variante())
	transicion_actual = escena.instantiate()
	var escena_actual: Node = get_tree().current_scene
	if escena_actual == null:
		add_child(transicion_actual)
	else:
		escena_actual.add_child(transicion_actual)
	transicion_actual.mostrar_datos(pisoActual, vidas, gano)
	await transicion_actual.transicion_terminada
	transicion_actual = null
