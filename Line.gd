extends Node2D

signal step_hit(step, lineid)

var color
var lineid
var start_time

var _destroy_after_duration = true
var _started = false
var _next_step
var _timeline

func _enter_tree():
	_next_step = 0
	_timeline = get_node("..")

func _ready():
	modulate = color
	$AnimationPlayer.play("show")

func _process(_delta):
	var elapsed = Time.get_ticks_msec() - start_time
	var width = _timeline.step_width * _timeline.steps
	var duration = _timeline.step_duration * _timeline.steps
	var _next_step_duration = _timeline.step_duration * _next_step

	if elapsed > 0:
		if not _started:
			$Particles.emitting = true
		position.x = width * min(elapsed as float / duration, 1.0)

		if elapsed > _next_step_duration:
			emit_signal("step_hit", _next_step, lineid)
			_next_step += 1

	if elapsed >= duration and _destroy_after_duration:
		destroy()

func destroy():
	$AnimationPlayer.play("hide")
	yield($AnimationPlayer, "animation_finished")
	emit_signal("step_hit", 1000, lineid)
	queue_free()
