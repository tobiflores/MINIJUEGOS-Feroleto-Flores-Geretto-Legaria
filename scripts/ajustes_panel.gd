extends Control

signal cerrado

@onready var slider_maestro: HSlider = $Filas/Maestro/Slider
@onready var slider_musica: HSlider = $Filas/Musica/Slider
@onready var slider_sfx: HSlider = $Filas/SFX/Slider
@onready var valor_maestro: Label = $Filas/Maestro/Valor
@onready var valor_musica: Label = $Filas/Musica/Valor
@onready var valor_sfx: Label = $Filas/SFX/Valor

func abrir() -> void:
	slider_maestro.set_value_no_signal(ajustes.maestro)
	slider_musica.set_value_no_signal(ajustes.musica)
	slider_sfx.set_value_no_signal(ajustes.sfx)
	_refrescar_textos()
	show()

func _refrescar_textos() -> void:
	valor_maestro.text = "%d%%" % ajustes.maestro
	valor_musica.text = "%d%%" % ajustes.musica
	valor_sfx.text = "%d%%" % ajustes.sfx

func _on_maestro_value_changed(valor: float) -> void:
	ajustes.maestro = int(valor)
	_cambio()

func _on_musica_value_changed(valor: float) -> void:
	ajustes.musica = int(valor)
	_cambio()

func _on_sfx_value_changed(valor: float) -> void:
	ajustes.sfx = int(valor)
	_cambio()

func _cambio() -> void:
	ajustes.aplicar()
	_refrescar_textos()

func _on_volver_pressed() -> void:
	ajustes.guardar()
	hide()
	cerrado.emit()
