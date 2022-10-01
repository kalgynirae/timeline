extends Node2D

var destroy = true
var duration = 10_000
var start_position = Vector2(150, 600)
var start_time
var started = false
var width = 1000

func _ready():
	position = start_position
	$AnimationPlayer.play("show")

func _process(_delta):
	var elapsed = Time.get_ticks_msec() - start_time
	if 0 < elapsed and elapsed < duration:
		if not started:
			start()
		position.x = start_position.x + width * elapsed / duration
	if elapsed > duration:
		stop()

func start():
	$Particles.emitting = true
	started = true

func stop():
	$AnimationPlayer.play("hide")
	if destroy:
		yield($AnimationPlayer, "animation_finished")
		queue_free()
