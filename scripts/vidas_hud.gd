extends HBoxContainer

const COLOR_LLENO: Color = Color(0.9, 0.15, 0.2)
const COLOR_VACIO: Color = Color(0.25, 0.2, 0.22)

var vidas_mostradas: int = -1

func actualizar(vidas: int) -> void:
	var corazones: Array[Node] = get_children()
	for i in corazones.size():
		var forma: Polygon2D = corazones[i].get_node("Forma")
		forma.color = COLOR_LLENO if i < vidas else COLOR_VACIO
		if vidas_mostradas > vidas and i == vidas:
			forma.scale = Vector2(1.7, 1.7)
			create_tween().tween_property(forma, "scale", Vector2.ONE, 0.35)
	vidas_mostradas = vidas
