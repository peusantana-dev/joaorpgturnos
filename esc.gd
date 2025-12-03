extends CanvasLayer

@onready var continue_b = $VBoxContainer/continue_b

func _ready():
	visible = false




func _unhandled_input(event):
	if event.is_action_pressed("esc"):
		visible = true
		get_tree().paused = true
		continue_b.grab_focus()



func _on_quit_b_pressed() -> void:
	get_tree().quit()


func _on_restart_b_pressed() -> void:
	#limpa todas as variáveis do Manager antes de reiniciar
	Manager.jogo_finalizado = false
	Manager.jogadores.clear()
	Manager.inimigos.clear()
	Manager.personagem_selecionado = null
	Manager.personagem_objetivo = null
	Manager.turno_jogador = true
	Manager.pode_abrir_menu = true

	#remove conexões antigas com personagens que não existem mais
	for c in Manager.get_signal_connection_list("jogador_seleciona_inimigo"):
		Manager.disconnect("jogador_seleciona_inimigo", c.callable)
	for c in Manager.get_signal_connection_list("ataque_iniciado"):
		Manager.disconnect("ataque_iniciado", c.callable)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://cenas/start.tscn")
	

func _on_continue_b_pressed() -> void:
	get_tree().paused = false
	visible = false
