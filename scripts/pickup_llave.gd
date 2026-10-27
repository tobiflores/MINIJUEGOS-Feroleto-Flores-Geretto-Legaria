extends Area2D

var agarrada := false

func _on_body_entered(_body: Node2D) -> void:
	if agarrada:
		return
	agarrada = true
	gestorPartida.agarrar_llave()
	queue_free()
