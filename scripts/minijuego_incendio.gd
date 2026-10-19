extends Node2D

signal termino(resultado: float)

@export var tiempoLimite: float = 10.0
@export var tiempoApagar: float = 1.0

var llamas: Array[TextureRect] = []
var intensidades: Array[float] = []
var apagadas: int = 0
var terminado: bool = false

func _ready() -> void:
	llamas = [$Llama1, $Llama2, $Llama3, $Llama4, $Llama5, $Llama6]
