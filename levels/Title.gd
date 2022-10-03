extends "res://Level.gd"

func _ready():
	$DevsText.visible = false

func start(start_time):
	get_node("/root/Game/MusicPlayer").play()
	yield(get_tree().create_timer(0.5, false), "timeout")
	$Timeline.spawn_line(Color("00ff00"))
