extends "res://Level.gd"

func _ready():
	$DevsText.visible = false
	get_node("/root/Game").thymefred = false

func start(_start_time):
	yield(get_tree().create_timer(0.5, false), "timeout")
	$Timeline.spawn_line(Color("00ff00"))
