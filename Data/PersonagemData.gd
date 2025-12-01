class_name PersonagemData extends Resource

@export var jogador : bool = true

# estatisticas
@export var saude_maxima : float = 100.0 #saude maxima dos personagens
@export var armadura : float = 1.0 #defesa dos personagens e inimigos 

# dano
@export var dano : float = 15.0 #dano base do personagem
@export var multiplicador_dano : float = 1.1 #serve para aumentar ou diminuir o dano final
@export var probabilidade_dano : float = 0.1 #chance de acertar ou causar efeito extra de dano. no caso 0.1 = 10%
