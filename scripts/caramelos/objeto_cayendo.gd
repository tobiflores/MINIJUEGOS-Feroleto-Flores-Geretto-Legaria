extends Area2D

@export var velocidad_caida: float = 200.0
var esCaramelo: bool = true

func _process(delta: float) -> void:
	position.y += velocidad_caida * delta

	if position.y > get_viewport_rect().size.y + 50:
		print("destruyendo objeto en y: ", position.y)
		queue_free()
