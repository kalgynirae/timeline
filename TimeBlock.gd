extends Node2D

export var type: String
export var duration: int

const COLORS = {
	"foo": Color("c04040"),
	"spawn_line": Color("00ff00"),
	"claw_down": Color("0000ff")
}

var active = false
var row
var start_step
var stop_step

var _activated_by = {}
var _timeline

func _enter_tree():
	_timeline = get_node("..")
	_timeline.register_block(self)

func _ready():
	$ColorRect.rect_size.x = duration as float / _timeline.step_duration * _timeline.step_width
	$ColorRect/Label.text = type
	$ColorRect.color = COLORS[type]

func _process(delta):
	if active:
		match type:
			"claw_down":
				get_node("/root/Game/CurrentLevel/TestC/Claw").MoveDown()

func activate(lineid):
	if _activated_by.empty():
		active = true
		modulate = Color("ffffff")
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
		modulate = Color("bbbbbb")
