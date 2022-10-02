extends "res://Level.gd"

const COLORS = [Color("00ff00"), Color("00ffff"), Color("ffff00")]
const TIME_PADDING = 250
const START_X = 150
const WIDTH = 1000

var _color = 0
var _start_time = null

func start():
	yield(get_tree().create_timer(0.5, false), "timeout")
	spawn_line()

func _process(_delta):
	if _start_time == null:
		return
	var elapsed = Time.get_ticks_msec() - _start_time
	if elapsed > 4_000 - TIME_PADDING:
		spawn_line()

func spawn_line():
	_start_time = Time.get_ticks_msec() + TIME_PADDING
	$Timeline.spawn_line(_start_time, COLORS[_color])
	_color = (_color + 1) % COLORS.size()
