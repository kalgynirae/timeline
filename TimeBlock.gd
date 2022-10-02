extends Node2D

export var type: String
export var duration: int

const COLORS = {
	"foo": Color("d04040"),
	"spawn_line": Color("20f020"),
	"claw_up": Color("3080f0"),
	"claw_down": Color("5080f0"),
	"claw_left": Color("7080f0"),
	"claw_right": Color("9080f0"),
	"claw_open": Color("37d67a"),
	"claw_close": Color("e91e63")
}

var active = false
var row
var start_step
var stop_step

var _activated_by = {}
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
	resize()
	$ColorRect/Label.text = type
	$ColorRect.color = COLORS.get(type, Color("c0c0c0"))
	$Particles.process_material.color = COLORS.get(type, Color("c0c0c0")).lightened(0.3)
	$Particles.process_material.color.a = 0.75

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

func activate(lineid):
	if _activated_by.empty():
		active = true
		$ColorRect.modulate = Color("ffffff")
		$Particles.emitting = true
		$ActiveSound.play()
		match type:
			"foo":
				print("foo")
			"spawn_line":
				_timeline.spawn_line(Time.get_ticks_msec() + duration, Color("00ff00"))
			"claw_open":
				get_node("/root/Game/CurrentLevel/TestC/Claw").Open()
			"claw_close":
				get_node("/root/Game/CurrentLevel/TestC/Claw").Close()
	_activated_by[lineid] = true

func deactivate(lineid):
	_activated_by.erase(lineid)
	if _activated_by.empty():
		active = false
		$ColorRect.modulate = Color("bbbbbb")
		$Particles.emitting = false
		$ActiveSound.stop()

func deactivate_all():
	_activated_by.clear()
	deactivate(0)

func grab(mouse_position):
	_grabbed = true
	_grab_offset = mouse_position - global_position
	print("_grab_offset=", _grab_offset)
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
