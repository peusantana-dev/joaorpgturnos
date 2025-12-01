extends Node
signal jogador_seleciona_inimigo() #inicia quando o jogador escolhe um inimigo
signal ataque_iniciado() #ativa quando o ataque é iniciado
signal mudar_turno(jogador: bool) #avisa de quem é o turno agora
signal partida_terminada(jogador: bool) #avisa quando alguém venceu


var turno_jogador : bool = true #controla de quem é o turno 
var pode_abrir_menu : bool = true #indica se o jogador pode abrir o menu de açõe

var personagem_selecionado #armazenam quem vai agir e quem é o alvo
var personagem_objetivo

var inimigos = [] #personagens vivos
var turno_inimigo : int = 0 #controla qual inimigo vai agir
var jogadores = [] #personagem vivos

var jogo_finalizado : bool = false #para impedir ações quando a partida acabar


func obter_personagens(): #atualiza os arrays de personagens vivos, garantindo que contenham apenas os nós ativos na cena.
	inimigos = get_tree().get_nodes_in_group("Inimigo")
	jogadores = get_tree().get_nodes_in_group("Jogador")
	
	if jogadores.is_empty() and not jogo_finalizado: #caso todos os jogadores tenham sido eliminados, marca fim de jogo, printam a mensagem, aguarda 1 segundo e troca para a cena de derrota
		jogo_finalizado = true
		print("Todos os jogadores morreram! Inimigo venceu")
		await get_tree().create_timer(1.0).timeout  #dá tempo para animação de morte
		get_tree().change_scene_to_file("res://cenas/defeat.tscn")
		return #impede qualquer outra ação 


#Se todos os inimigos morreram (opcional)
	if inimigos.is_empty() and not jogo_finalizado: #caso todos os inimigos tenham sido eliminados, maca fim de jogo e muda para a cena de vitória
		jogo_finalizado = true
		print("Todos os inimigos morreram! Jogador venceu")
		await get_tree().create_timer(0).timeout
		get_tree().change_scene_to_file("res://cenas/win.tscn")

func trocar_turno(): 
	turno_jogador = !turno_jogador #alterna entre turno do jogador e turno do inimigo
	emit_signal("mudar_turno", turno_jogador) #alterna entre turno do jogador e turno do inimigo
	
	print(turno_jogador)
	if turno_jogador == false: #caso seja o turno do inimigo, aguarda 1 segundo e inicia a lógica de ataque inimigo, se o jogo ainda não terminou
		await get_tree().create_timer(1).timeout
		if jogo_finalizado:
			return
		iniciar_turno_inimigo()
	else:
		for j in jogadores: #caso seja o turno do jogador, remove qualquer buff de defesa de todos os jogadores válidos
			if is_instance_valid(j):  #só executa se o jogador ainda existir
				j.remover_defesa()
	


func mostrar_selecao(): #desativa abertura de menu e sinaliza que o jogador selecionou um inimigo
	pode_abrir_menu = false 
	emit_signal("jogador_seleciona_inimigo")


func estabelecer_personagem(personagem): #define qual personagem realizará a ação
	personagem_selecionado = personagem
	
func estabelecer_objetivo(personagem): #define qual sera o alvo
	personagem_objetivo = personagem

func iniciar_ataque(): #dispara sinal de início de ataque e executa o ataque do personagem selecionado sobre o alvo.
	emit_signal("ataque_iniciado")
	personagem_selecionado.atacar_personagem(personagem_objetivo)


func defender_personagem(): #faz com que o personagem selecionado entre no estado de defesa
	personagem_selecionado.defender()

func iniciar_turno_inimigo(): #reinicia o índice de ataque do inimigo caso todos tenham atuado.
	if turno_inimigo >= inimigos.size():
		turno_inimigo = 0
	
	
	var inimigo_atual = inimigos[turno_inimigo]
	
	if (randf_range(0,100) < 90): 
		# função atacar. decisão do inimigo neste caso, ele sempre ataca (probabilidade = 100%)
		estabelecer_personagem(inimigo_atual)
		estabelecer_objetivo(jogadores.pick_random())
		iniciar_ataque()
	else:
		estabelecer_personagem(inimigo_atual)
		defender_personagem()
	turno_inimigo += 1 #atualiza índice para o próximo inimigo
