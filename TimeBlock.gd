extends Node2D

export var type: String
export var duration: int

const COLORS = {
	"foo": Color("d04040"),
	"spawn_line": Color("20f020"),
	"claw_down": Color("3080f0")
}

var active = false
var chosen = false
var row
var start_step
var stop_step

var _activated_by = {}
var _timeline

func _enter_tree():
	_timeline = get_node("..")
	_timeline.register_block(self)

func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		if $ColorRect.get_global_rect().has_point(event.position):
			toggle_choose()

func _ready():
	$ColorRect.rect_size.x = duration as float / _timeline.step_duration * _timeline.step_width
	$ColorRect/Label.text = type
	$ColorRect.color = COLORS.get(type, Color("c0c0c0"))
	$Particles.amount = $ColorRect.rect_size.x / 2
	$Particles.position = $ColorRect.rect_size / 2
	$Particles.process_material.emission_box_extents.x = max($ColorRect.rect_size.x / 2 - 15, 5)
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

func choose():
	chosen = true
	$Particles.emitting = true
	$AnimationPlayer.play("blink")

func unchoose():
	chosen = false
	$Particles.emitting = false
	$AnimationPlayer.play("RESET")

func toggle_choose():
	if chosen:
		unchoose()
	else:
		choose()
