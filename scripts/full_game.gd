extends Node3D

var game:Node3D

func _ready() -> void:
	%MessagePanelContainer.visible=false
	new_game()

func new_game():
	if game!=null:
		game.free()
	game=preload("res://scenes/game.tscn").instantiate()
	game.won.connect(_on_won)
	game.lost.connect(_on_lost)
	add_child(game)

func stop_game():
	game.process_mode=Node.PROCESS_MODE_DISABLED

func _on_won():
	stop_game()
	%MessagePanelContainer.visible=true
	%MessageLabel.text="YOU HAVE WON!"
	%MessageLabel.label_settings.font_color=Color.from_rgba8(255,255,255)
	%RestartButton.text="Play again"

func _on_lost():
	stop_game()
	%MessagePanelContainer.visible=true
	%MessageLabel.text="YOU HAVE LOST"
	%MessageLabel.label_settings.font_color=Color.from_rgba8(255,0,0)
	%RestartButton.text="Try again"

func _on_restart_button_pressed() -> void:
	%MessagePanelContainer.visible=false
	new_game()
