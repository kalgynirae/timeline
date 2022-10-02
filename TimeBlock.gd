extends Node2D

export var type: String
export var duration: int

const COLORS = {
	"foo": Color("d04040"),
	"spawn_line": Color("20f020"),
	"claw_down": Color("3080f0")
}

var active = false
var row
var start_step
var stop_step

var _activated_by = {}
var _grabbed = false
var _grab_offset
var _timeline

func _enter_tree():
	_timeline = get_node("..")
	_timeline.register_block(self)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if not _grabbed and $ColorRect.get_global_rect().has_point(event.position):
				grab(event.position)
			elif _grabbed:
				ungrab()
	if event is InputEventMouseMotion and _grabbed:
		global_position = event.position - _grab_offset
		_timeline.snap_block(self)

func _ready():
	$ColorRect.rect_size.x = duration as float / _timeline.step_duration * _timeline.step_width
	$ColorRect/Label.text = type
	$ColorRect.color = COLORS.get(type, Color("c0c0c0"))
	$Particles.amount = $ColorRect.rect_size.x
	$Particles.position = $ColorRect.rect_size / 2
	$Particles.process_material.emission_box_extents.x = max($ColorRect.rect_size.x / 2 - 5, 5)
	$Particles.process_material.color = COLORS.get(type, Color("c0c0c0")).lightened(0.3)
	$Particles.process_material.color.a = 0.75

func _process(delta):
	if active:
		match type:
			"claw_down":
				get_node("/root/Game/CurrentLevel/TestC/Claw").MoveDown()

func activate(lineid):
	if _activated_by.empty():
		active = true
		$ColorRect.modulate = Color("ffffff")
		$Particles.emitting = true
		match type:
			"foo":
				print("foo")
			"spawn_line":
				_timeline.spawn_line(Time.get_ticks_msec() + duration, Color("00ff00"))
	_activated_by[lineid] = true

func deactivate(lineid):
	_activated_by.erase(lineid)
	if _activated_by.empty():
		active = false
		$ColorRect.modulate = Color("bbbbbb")
		$Particles.emitting = false

func deactivate_all():
	_activated_by.clear()
	deactivate(0)

func grab(mouse_position):
	_grabbed = true
	_grab_offset = mouse_position - global_position
	print("_grab_offset=", _grab_offset)
	$AnimationPlayer.play("blink")
	_timeline.unregister_block(self)

func ungrab():
	_grabbed = false
	$AnimationPlayer.play("RESET")
	_timeline.register_block(self)
