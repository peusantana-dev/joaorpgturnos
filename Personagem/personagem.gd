class_name Personagem extends CharacterBody2D

@export var Data : PersonagemData #guarda os dados do personagem (HP, ataque, defesa, se é jogador ou inimigo)
@onready var animation: AnimatedSprite2D = $Animation #referência ao sprite animado do personagem
@onready var componente_saude: Node = $ComponenteSaude #nó que controla HP, barra de vida e armadura



var personagem_objetivo #quem o personagem vai atacar
var atacando : bool = false #se ele está atualmente atacando
var defendendo : bool = false #se está defendendo


var voltar_posicao : bool = false #se deve voltar a posição inicial depois de atacar
var posicao_inicial : Vector2 #posição de origem do personagem na batalha



const VELOCITY = 600 #velocidade de movimento durante ataques e deslocamento do personagem

func _ready(): #inicializa a animação para “idle”(parado), define a posição inicial e configura atributos de vida e armadura do personagem
	animation.play("idle")
	posicao_inicial = global_position
	
	componente_saude.saude_maxima = Data.saude_maxima
	componente_saude.saude_atual = Data.saude_maxima
	componente_saude.armadura = Data.armadura
	componente_saude.atualizar_progress_bar()
	
	
	if Data.jogador == false: #adiciona o nó a grupos “jogador” ou “inimigo”
		add_to_group("Inimigo")
		animation.flip_h = true
		Manager.connect("jogador_seleciona_inimigo", mostrar_selecao)
		Manager.connect("ataque_iniciado", ocultar_selecao)
	else:
		add_to_group("Jogador")
 #os inimigos se conectam a sinais do Manager para mostrar/ocultar seleção


func _on_panel_gui_input(event: InputEvent) -> void: 
	if componente_saude.sem_saude or Manager.jogo_finalizado: #impede interação se o personagem está morto ou o jogo acabou
		return
	
	if Data.jogador: #o jogador pode abrir o menu de ações clicando no personagem apenas no turno dele
		if Input.is_action_just_pressed("mouse_esquerdo") and Manager.pode_abrir_menu and Manager.turno_jogador:
			$"Ações".abrir_menu()
			Manager.estabelecer_personagem(self)
	else: #inimigo seleciona alvo quando clicado (usado para debug, testes ou seleção manual)
		if Input.is_action_just_pressed("mouse_esquerdo") and $Selecionar.visible:
			Manager.estabelecer_objetivo(self)
			Manager.iniciar_ataque()


func _physics_process(delta):
	if componente_saude.sem_saude or Manager.jogo_finalizado: #bloqueia movimento e ataque se o personagem morreu ou o jogo acabou
		return
		
	if personagem_objetivo and atacando == false:
		 # faz o personagem ou inimigo se mover em direção ao alvo e ataca quando perto
		var distancia = global_position.distance_to(personagem_objetivo.global_position)
		if distancia > 150.0:
			var direcao = (personagem_objetivo.global_position - global_position).normalized()
			velocity = VELOCITY * direcao
			move_and_slide()
			animation.play("move")
		else:
			#atacar o personagem
			atacando = true
			animation.play("attack")
	
	
	if voltar_posicao: #faz o personagem retornar ao ponto de origem após ataque
		var distancia = global_position.distance_to(posicao_inicial)
#se a distância for maior que 0, o personagem ainda não chegou
		if distancia > 1:
			var direcao = (posicao_inicial - global_position).normalized()  #pega a direção normalizada
			velocity = VELOCITY * direcao
			move_and_slide()
			animation.play("move")
		else:
			voltar_posicao = false
			animation.play("idle")
			Manager.trocar_turno()
			Manager.pode_abrir_menu = true
		


### FUNÇÕES GERAIS
func atacar_personagem(target): #define o alvo que será atacado
	personagem_objetivo = target
	

func defender(): #ativa defesa, dobra a armadura, muda o turno e muda a cor do personagem ou inimigo
	componente_saude.armadura = Data.armadura*2
	defendendo = true
	Manager.trocar_turno()
	Manager.pode_abrir_menu = true
	animation.self_modulate = Color("2bc24c")
func remover_defesa(): #restaura armadura normal e cor do personagem.
	componente_saude.armadura = Data.armadura
	animation.self_modulate = Color(1, 1, 1)
	
	
### AÇÂO DO INIMIGO
func mostrar_selecao(): #deixa visivel a seta que fica em cima do personagem
	$Selecionar.visible = true


func ocultar_selecao(): #oculta a seta que fica em cima do personagem
	$Selecionar.visible = true



func _on_animation_animation_finished() -> void: #aplica dano ao alvo, reseta estado de ataque e volta a posição inicial
	if animation.animation == "attack":
		print("dar dano ao personagem")
		personagem_objetivo.componente_saude.receber_dano(Data.dano, Data.probabilidade_dano, Data.multiplicador_dano)
		
		personagem_objetivo = null
		atacando = false
		voltar_posicao = true
	if animation.animation == "dano": #troca para idle(parado) após o dano é remove o personagem da cena quando a animação de morte termina
		animation.play("idle")
	if animation.animation == "dead":
		await get_tree().create_timer(1).timeout
		queue_free()
		
func _on_componente_saude_dano_recebido() -> void: #ativa animação de dano e reseta defesa
	animation.play("dano")
	defendendo = false
	componente_saude.armadura = Data.armadura
	remover_defesa()
func _on_componente_saude_saude_zero() -> void: #começa a animação de morte e oculta a barra de vida
	animation.play("dead")
	$Saude.visible = false


	if Data.jogador:  #remove o personagem do grupo e das listas do manager
		remove_from_group("Jogador")
		Manager.jogadores.erase(self)
	else:    #atualiza arrays de personagens vivos é também checa vitória ou derrota.
		remove_from_group("Inimigo")
		Manager.inimigos.erase(self)
		
		#espera a animação de morte terminar antes de remover o personagem da cena
		await get_tree().create_timer(0.5).timeout
		queue_free()  #remove o personagem da cena
		
	if is_instance_valid(Manager): #chama o manager para checar se o jogo terminou automaticamente
		Manager.obter_personagens()
		
	if Manager.jogo_finalizado or componente_saude.sem_saude:
		return
