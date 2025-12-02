extends CanvasLayer

@onready var continue_b = $VBoxContainer/continue_b

var paused = false

func _ready() -> void:
	visible = false
	
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		visible = true
		get_tree().paused = true
		continue_b.grab_focus()
		





func _on_continue_b_pressed() -> void:
	get_tree().paused = false
	visible = false


func _on_quit_b_pressed() -> void: #chama a função de sair do jogo
	get_tree().quit()


func _on_restart_b_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/start.tscn")
