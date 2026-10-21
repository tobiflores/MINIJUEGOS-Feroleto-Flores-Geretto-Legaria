extends CharacterBody2D

@export var velocidad: float = 250.0
@export var margen: float = 40.0

func _physics_process(_delta: float) -> void:
	velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * velocidad
	move_and_slide()

	var limite: Vector2 = get_viewport_rect().size - Vector2(margen, margen)
	position = position.clamp(Vector2(margen, margen), limite)
