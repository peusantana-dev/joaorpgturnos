extends Control



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

	#volta pra tela inicial
	get_tree().change_scene_to_file("res://cenas/start.tscn") #chama a cena para voltar a jogar


func _on_quit_b_pressed() -> void: #chama a função de sair do jogo
	get_tree().quit()
