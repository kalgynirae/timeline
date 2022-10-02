extends Node2D

export var type: String
export var duration: int

const COLORS = {
	"foo": Color("c04040"),
}

var active = false
var row
var start_step
var stop_step

var _timeline

func _enter_tree():
	_timeline = get_node("..")
	_timeline.register_block(self)

func _ready():
	$ColorRect.rect_size.x = duration * _timeline.colwidth
	$ColorRect/Label.text = type
	$ColorRect.color = COLORS[type]

#func _process(delta):
#	pass

func activate():
	active = true
	modulate = Color("ffffff")

func deactivate():
	active = false
	modulate = Color("bbbbbb")
