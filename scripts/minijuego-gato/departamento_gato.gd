extends Node2D

signal termino(resultado: float)

@export var distanciaHablar: float = 130.0
@export var escenaMinijuego: PackedScene

var dialogoAbierto: bool = false
var minijuegoIniciado: bool = false

func _process(_delta: float) -> void:
	if minijuegoIniciado:
		return

	var distancia: float = $Apartamento/Jugador.global_position.distance_to($Apartamento/Vecino.global_position)
	$Interfaz/EtiquetaHablar.visible = distancia < distanciaHablar and not dialogoAbierto

func _unhandled_input(event: InputEvent) -> void:
	if minijuegoIniciado:
		return
	if not event.is_action_pressed("interactuar"):
		return
	get_viewport().set_input_as_handled()

	if not dialogoAbierto:
		if $Interfaz/EtiquetaHablar.visible:
			abrirDialogo()
	else:
		aceptar()

func abrirDialogo() -> void:
	dialogoAbierto = true
	$Apartamento/Jugador.velocity = Vector2.ZERO
	$Apartamento/Jugador.set_physics_process(false)
	$Interfaz/EtiquetaHablar.hide()
	$Interfaz/Dialogo.show()

func aceptar() -> void:
	minijuegoIniciado = true
	$Interfaz/Dialogo.hide()
	$Apartamento.hide()

	var minijuego = escenaMinijuego.instantiate()
	minijuego.termino.connect(_cuando_termina_minijuego)
	add_child(minijuego)

func _cuando_termina_minijuego(resultado: float) -> void:
	termino.emit(resultado)
