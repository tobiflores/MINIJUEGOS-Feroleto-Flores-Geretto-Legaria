extends CharacterBody2D

@export var velocidad: float = 250.0
@export var margen: float = 40.0
@export var texturaIzquierda: Texture2D
@export var texturaDerecha: Texture2D

func _physics_process(_delta: float) -> void:
	velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * velocidad
	move_and_slide()

	if velocity.x < 0:
		$Sprite2D.texture = texturaIzquierda
	elif velocity.x > 0:
		$Sprite2D.texture = texturaDerecha

	var limite: Vector2 = get_viewport_rect().size - Vector2(margen, margen)
	position = position.clamp(Vector2(margen, margen), limite)
