extends Node2D

const COLORS = [Color("00ff00"), Color("00ffff"), Color("ffff00")]
const TIME_PADDING = 250
const START_X = 150
const WIDTH = 1000

var line_scene = preload("res://Line.tscn")

var color = 0
var start_time = 0

func _ready():
	var timer = Timer.new()
	yield(get_tree().create_timer(0.5, false), "timeout")
	start()

func _process(delta):
	var elapsed = Time.get_ticks_msec() - start_time
	if elapsed > 5_000 - TIME_PADDING:
		start()

func start():
	start_time = Time.get_ticks_msec() + TIME_PADDING
	var line = line_scene.instance()
	line.modulate = COLORS[color]
	color = (color + 1) % COLORS.size()
	line.start_time = start_time
	add_child(line)
