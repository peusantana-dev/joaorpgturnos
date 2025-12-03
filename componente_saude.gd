extends Node
signal saude_zero() #ativa quando a vida do personagem chega a 0
signal dano_recebido() #ativa quando o personagem sofre dano, mais ainda está vivo


@export var progress_bar : ProgressBar #barra de vida visivel na cena


var saude_maxima : float #controla a vida do personagem
var saude_atual : float

var armadura : float #reduz o dano recebido

var sem_saude : bool = false #indica se o personagem já está morto, para bloquear danos futuros


func receber_dano(quantidade: float, prob: float, aum: float):
	
	if sem_saude: #bloqueia o dano se o personagem já estiver morto
		return
	
	
	saude_atual -= calcular_dano(quantidade, prob, aum) #calcula o dano final
	

	print("Dano recebido:", quantidade)
	atualizar_progress_bar() #atualiza a barra de vida
	
	
	if (saude_atual <= 0):
		emit_signal("saude_zero") #emite o sinal certo dependendo se já morreu ou não
	else:
		emit_signal("dano_recebido")

func calcular_dano(quantidade: float, prob: float, aum: float) -> float:  #calcula o dano em três fatores "quantida: dano base, prob: chance de multiplicar dano(aum: multiplidor)
	#armadura: divide o dano para reduzir o efeito" é retorna o dano final que sera subtraído da vida atual
	var resultado : float = quantidade
	
	if (randf_range(0,1)) >= prob:
		resultado = quantidade * aum
	
	#calcular armadura
	resultado = resultado / armadura
	
	
	return resultado

func atualizar_progress_bar(): #atualiza visualmente a barra de vida com o valor atual
	if progress_bar:
		progress_bar.value = saude_atual / saude_maxima
