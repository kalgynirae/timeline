extends Node2D

const COLORS = [Color("00ff00"), Color("00ffff"), Color("ffff00")]
const TIME_PADDING = 250
const START_X = 150
const WIDTH = 1000

var color = 0
var start_time = 0

func _ready():
	yield(get_tree().create_timer(0.5, false), "timeout")
	start()

func _process(_delta):
	var elapsed = Time.get_ticks_msec() - start_time
	if elapsed > 4_000 - TIME_PADDING:
		start()

func start():
	start_time = Time.get_ticks_msec() + TIME_PADDING
	$Timeline.spawn_line(start_time, COLORS[color])
	color = (color + 1) % COLORS.size()
