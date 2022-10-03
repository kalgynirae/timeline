extends Node2D

export var type: String
export var duration: int
export var dark: bool

const COLORS = {
	"foo": Color("d04040"),
	"spawn_line": Color("c0c0c0"),
	"lock": Color("c0c0c0"),
	"claw_up": Color("3080f0"),
	"claw_down": Color("5080f0"),
	"claw_left": Color("7080f0"),
	"claw_right": Color("9080f0"),
	"claw_open": Color("37d67a"),
	"claw_close": Color("e91e63"),
	"tf_left": Color("37d67a"),
	"tf_right": Color("e91e63"),
	"tf_jump": Color("9080f0")
}

var active = false
var row
var start_step
var stop_step

var _activated_by = {}
var _audio_volume
var _grabbed = false
var _grab_offset
var _locked = false
var _timeline

func _enter_tree():
	_timeline = get_node("%Timeline")
	_timeline.register_block(self, true)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed and not _locked:
			if not _grabbed and $ColorRect.get_global_rect().has_point(event.position):
				grab(event.position)
			elif _grabbed:
				ungrab()
	if event is InputEventMouseMotion and _grabbed:
		global_position = event.position - _grab_offset
		_timeline.snap_block(self, false)

func _ready():
	if _audio_volume == null:
		_audio_volume = $ActiveSound.volume_db
	resize()
	$ColorRect/Label.text = type
	$ColorRect.color = COLORS.get(type, Color("c0c0c0"))
	$Particles.process_material = $Particles.process_material.duplicate()
	$Particles.process_material.color = COLORS.get(type, Color("c0c0c0")).lightened(0.3)
	$Particles.process_material.color.a = 0.75
	$DarkParticles.process_material = $DarkParticles.process_material.duplicate()
	if dark:
		$DarkParticles.emitting = true

func _process(delta):
	if active:
		match type:
			"claw_up":
				get_node("/root/Game/CurrentLevel/TestC/Claw").MoveUp()
			"claw_down":
				get_node("/root/Game/CurrentLevel/TestC/Claw").MoveDown()
			"claw_left":
				get_node("/root/Game/CurrentLevel/TestC/Claw").MoveLeft()
			"claw_right":
				get_node("/root/Game/CurrentLevel/TestC/Claw").MoveRight()

func resize():
	var size_x = duration as float / _timeline.step_duration * _timeline.step_width
	$ColorRect.rect_size.x = abs(size_x)
	if size_x < 0:
		position.x += size_x
	$Particles.amount = $ColorRect.rect_size.x
	$Particles.position = $ColorRect.rect_size / 2
	$Particles.process_material.emission_box_extents.x = max($ColorRect.rect_size.x / 2 - 5, 5)
	$DarkParticles.amount = $ColorRect.rect_size.x / 4
	$DarkParticles.position = $ColorRect.rect_size / 2
	$DarkParticles.process_material.emission_box_extents.x = max($ColorRect.rect_size.x / 2 - 5, 5)

func activate(lineid):
	if _activated_by.empty():
		active = true
		$ColorRect.modulate = Color("ffffff")
		$Particles.emitting = true
		$ActiveSound.volume_db = -9.0
		$ActiveSound.play()
		match type:
			"foo":
				print("foo")
			"lock":
				_timeline.lock()
			"spawn_line":
				_timeline.spawn_line(Color("00ff00"))
			"claw_open":
				get_node("/root/Game/CurrentLevel/TestC/Claw").Open()
			"claw_close":
				get_node("/root/Game/CurrentLevel/TestC/Claw").Close()
			"tf_left":
				get_node("%Timefred").StartMoveLeft()
	_activated_by[lineid] = true

func deactivate(lineid):
	_activated_by.erase(lineid)
	if _activated_by.empty() and active:
		active = false
		$ColorRect.modulate = Color("bbbbbb")
		$Particles.emitting = false
		var tween = create_tween()
		tween.tween_property($ActiveSound, "volume_db", -20.0, 0.4)
		yield(tween, "finished")
		$ActiveSound.stop()
		$ActiveSound.volume_db = _audio_volume

func deactivate_all():
	_activated_by.clear()
	deactivate(0)

func grab(mouse_position):
	_grabbed = true
	_grab_offset = mouse_position - global_position
	_timeline.unregister_block(self)
	$AnimationPlayer.play("blink")

func ungrab():
	_grabbed = false
	if _timeline.register_block(self, false):
		$AnimationPlayer.play("RESET")
	else:
		$AnimationPlayer.play("disabled")

func lock():
	_locked = true

func unlock():
	_locked = false
