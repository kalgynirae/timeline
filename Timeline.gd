extends Node2D

var start_time = 0

func _ready():
	pass

#func _process(delta):
#	pass

func _on_Game_started(msec):
	$particles.emitting = true
