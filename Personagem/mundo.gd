extends Node2D

func _process(delta):
	if Input.is_action_just_pressed("trocar_cena"):
		get_tree().change_scene_to_file("res://cenas/esc.tscn")	
		
func _ready(): #sempre que o manager alternar o turno, essa função vai ser chamada automaticamente
	await get_tree().process_frame  #espera 1 frame pra garantir que tudo carregou
	Manager.obter_personagens()   #faz o manager procurar novos personagens assim que a cena for carregada
	Manager.jogo_finalizado = false
	Manager.pode_abrir_menu = true
	Manager.connect("mudar_turno", atualizar_turno) 


func _on_iniciar_mundo_timeout() -> void: #atualiza as listas de jogadores e inimigos no manager para garantir que os dados estejam corretos no início do jogo
	Manager.obter_personagens()



func atualizar_turno(jogador: bool): #atualiza o label na tela para mostrar “Turno: JOGADOR” ou “Turno: INIMIGO”
	if jogador: $Label.text = "Turno: JOGADOR"
	else: $Label.text = "Turno: INIMIGO"
#recebe true ou false indicando de quem é o turno
