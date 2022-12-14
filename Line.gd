extends Node2D

signal step_hit(step, lineid, dark)
signal vanish(lineid, dark)

var color
var dark = false
var lineid
var start_time

var _destroy_after_duration = true
var _destroying = false
var _started = false
var _next_step
var _timeline

func _enter_tree():
	_next_step = 0
	_timeline = get_node("..")

	var music = get_node("/root/Game/MusicPlayer")
	var pos = music.get_playback_position()
	var offset = (1000 * (1 - (pos - floor(pos)))) as int % 500
	if offset < 100:
		offset += 500
	start_time = Time.get_ticks_msec() + offset - 10

func _ready():
	modulate = color
	if dark:
		$DarkParticles.emitting = true
	$AnimationPlayer.play("show")
	if not dark:
		$SpawnSound.play(0.05)

func _process(_delta):
	var elapsed = Time.get_ticks_msec() - start_time
	var width = _timeline.step_width * _timeline.steps
	var duration = _timeline.step_duration * _timeline.steps
	var _next_step_duration = _timeline.step_duration * _next_step

	if elapsed > 0:
		if not _started:
			_started = true
			$Particles.emitting = true
			if not dark:
				$StartSound.play()
		position.x = width * min(elapsed as float / duration, 1.0)

		if elapsed > _next_step_duration:
			emit_signal("step_hit", _next_step, lineid, dark)
			_next_step += 1

	if elapsed >= duration and _destroy_after_duration:
		destroy()

func destroy():
	if _destroying:
		return
	_destroying = true
	$AnimationPlayer.play("hide")
	yield($AnimationPlayer, "animation_finished")
	emit_signal("vanish", lineid, dark)
	queue_free()

func set_height(rows: int):
	$VLine.points[0].y = -rows * _timeline.row_height
	$Top.position.y = -rows * _timeline.row_height
	$Particles.process_material.emission_box_extents.y = rows * _timeline.row_height / 2
	$Particles.position.y = -rows * _timeline.row_height / 2
	$Particles.amount = 6 * rows
	$DarkParticles.process_material.emission_box_extents.y = rows * _timeline.row_height / 2
	$DarkParticles.position.y = -rows * _timeline.row_height / 2
	$DarkParticles.amount = 3 * rows
