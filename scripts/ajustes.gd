extends Node

const RUTA_ARCHIVO: String = "user://ajustes.cfg"

var maestro: int = 100
var musica: int = 100
var sfx: int = 100

func _ready() -> void:
	cargar()
	aplicar()

func aplicar() -> void:
	_poner_volumen("Master", maestro)
	_poner_volumen("Musica", musica)
	_poner_volumen("SFX", sfx)

func guardar() -> void:
	var archivo := ConfigFile.new()
	archivo.set_value("volumen", "maestro", maestro)
	archivo.set_value("volumen", "musica", musica)
	archivo.set_value("volumen", "sfx", sfx)
	archivo.save(RUTA_ARCHIVO)

func cargar() -> void:
	var archivo := ConfigFile.new()
	if archivo.load(RUTA_ARCHIVO) != OK:
		return
	maestro = archivo.get_value("volumen", "maestro", maestro)
	musica = archivo.get_value("volumen", "musica", musica)
	sfx = archivo.get_value("volumen", "sfx", sfx)

func _poner_volumen(bus: String, porcentaje: int) -> void:
	var indice: int = AudioServer.get_bus_index(bus)
	if indice < 0:
		return
	AudioServer.set_bus_mute(indice, porcentaje <= 0)
	AudioServer.set_bus_volume_db(indice, linear_to_db(porcentaje / 100.0))
