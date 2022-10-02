extends "res://Level.gd"

const COLORS = [Color("00ff00"), Color("00ffff"), Color("ffff00")]
const TIME_PADDING = 250

var _color = 0
var _next_spawn = null

func start(start_time):
	_next_spawn = start_time - TIME_PADDING;

func _process(_delta):
	if Time.get_ticks_msec() > _next_spawn:
		spawn_line()
		_next_spawn += 4_000

func spawn_line():
	$Timeline.spawn_line(_next_spawn + TIME_PADDING, COLORS[_color])
	_color = (_color + 1) % COLORS.size()
