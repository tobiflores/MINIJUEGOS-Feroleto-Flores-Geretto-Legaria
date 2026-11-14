extends CanvasLayer

@export var duracion: float = 1.2

@onready var destello: ColorRect = $Destello
@onready var cartel: Control = $Cartel
@onready var texto: Label = $Cartel/Texto
@onready var sonido_ganar: AudioStreamPlayer = $SonidoGanar
@onready var sonido_perder: AudioStreamPlayer = $SonidoPerder

func mostrar(gano: bool, titulo: String) -> void:
	var color: Color = Color(0.4, 1.0, 0.5) if gano else Color(1.0, 0.35, 0.3)
	texto.text = titulo
	texto.add_theme_color_override("font_color", color)

	destello.color = Color(color, 0.35)
	create_tween().tween_property(destello, "color:a", 0.0, 0.5)

	cartel.modulate.a = 1.0
	cartel.show()
	create_tween().tween_property(cartel, "scale", Vector2.ONE, 0.25) \
			.from(Vector2(0.6, 0.6)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	var sonido: AudioStreamPlayer = sonido_ganar if gano else sonido_perder
	if sonido.stream != null:
		sonido.play()
	if not gano:
		_sacudir_escena()

	await get_tree().create_timer(duracion).timeout
	var salida: Tween = create_tween()
	salida.tween_property(cartel, "modulate:a", 0.0, 0.25)
	await salida.finished
	cartel.hide()

func _sacudir_escena() -> void:
	var escena := get_parent() as Node2D
	if escena == null:
		return
	var origen: Vector2 = escena.position
	var tween: Tween = create_tween()
	for i in 6:
		tween.tween_property(escena, "position", origen + Vector2(randf_range(-8.0, 8.0), randf_range(-6.0, 6.0)), 0.04)
	tween.tween_property(escena, "position", origen, 0.04)
