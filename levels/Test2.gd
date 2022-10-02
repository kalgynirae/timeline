extends "res://Level.gd"

func start(start_time):
	$Timeline.spawn_line(start_time, Color("00ff00"))

func _process(_delta):
	pass
