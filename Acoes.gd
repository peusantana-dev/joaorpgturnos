extends Control





func _ready(): #garante que o menu de ações não apareça sozinho quando a cena começa
	run_menu()


func abrir_menu(): #abre o menu ao clicar no "jogador"
	for p in get_tree().get_nodes_in_group("Jogador"): 
		p.get_node("Ações").run_menu()
	visible = true
	
	
func run_menu(): #essa função é usada tanto ao iniciar o menu quanto depois de apertar um botão de ação
	visible = false


func _on_b_attack_button_down() -> void: #button de ataque ao inimigo 
	run_menu() # esconde o menu
	Manager.mostrar_selecao() #mostra a seta de seleção do inimigo
	print("ATTACK")

func _on_b_defense_button_down() -> void: #button de defesa
	run_menu() #esconde o menu
	Manager.defender_personagem() #faz o personagem defender (aumentar a armadura, etc)
	print("DEFENSE")


func _on_b_run_button_down() -> void:
	get_tree().change_scene_to_file("res://cenas/defeat.tscn")
	run_menu()
