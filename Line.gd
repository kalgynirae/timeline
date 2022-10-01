extends Node2D

var start_time

var destroy_after_duration = true
var started = false
var timeline

func _enter_tree():
	timeline = get_node("..")

func _ready():
	$AnimationPlayer.play("show")

func _process(_delta):
	var elapsed = Time.get_ticks_msec() - start_time
	var width = timeline.colwidth * timeline.steps
	var duration = timeline.step_duration * timeline.steps
	
	if 0 < elapsed and elapsed < duration:
		if not started:
			$Particles.emitting = true
		position.x = width * elapsed / duration
	if elapsed > duration and destroy_after_duration:
		destroy()

func destroy():
	$AnimationPlayer.play("hide")
	yield($AnimationPlayer, "animation_finished")
	queue_free()
