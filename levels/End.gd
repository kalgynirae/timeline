extends "res://Level.gd"

func _ready():
	$DevsText.visible = false
	get_node("/root/Game").thymefred = true

func start(_start_time):
	$Timeline.spawn_line(Color("00ff00"))
