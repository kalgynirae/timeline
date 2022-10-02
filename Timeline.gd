extends Node2D

export var rows = 5
export var locked_rows = 1

var step_width = 25
var row_height = 50

var line_start_position = Vector2(100, -311)
var step_duration = 250
var steps = 40
var primary_every = 4

var line_scene = preload("res://Line.tscn")
var number_theme = load("res://TimelineNumbers.tres")

var _blocks = []
var _next_lineid = 1

func _ready():
	generate()

func _input(event):
	if event is InputEventMouseMotion:
		if event.button_mask & BUTTON_MASK_MIDDLE:
			position = event.position
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			step_width += 5
			generate()
		if event.button_index == BUTTON_WHEEL_DOWN:
			step_width -= 5
			generate()

#func _process(delta):
#	pass

func clear():
	for node in $verticals.get_children():
		node.queue_free()
	for node in $horizontals.get_children():
		node.queue_free()
	for node in $numbers.get_children():
		node.queue_free()
	for node in $subverticals.get_children():
		node.queue_free()

func generate():
	clear()
	var height = rows * row_height
	for i in range(11):
		var line
		if i == 0 or i == 10:
			line = vertical(i*step_width*primary_every, height, 8)
		else:
			line = vertical(i*step_width*primary_every, height, 4)
		line.name = "vertical" + i as String
		$verticals.add_child(line)
		$numbers.add_child(number(i*step_width*primary_every, i as String))
	for i in range(10):
		$subverticals.add_child(vertical(i*step_width*primary_every + step_width*primary_every/2, height, 1))
	for i in range(rows+1):
		$horizontals.add_child(horizontal(-i*row_height, steps*step_width, 2))

func vertical(x, height, width):
	var line = Line2D.new()
	line.points = [Vector2(x, 1), Vector2(x, -(height+1))]
	line.width = width
	return line

func horizontal(y, length, width):
	var line = Line2D.new()
	line.points = [Vector2(0, y), Vector2(length, y)]
	line.width = width
	return line

func number(x, text):
	var container = Control.new()
	container.rect_position = Vector2(x - abs(step_width), - (row_height / 10))
	container.rect_size = Vector2(abs(step_width * 2), row_height)
	var number = Label.new()
	number.align = Label.ALIGN_CENTER
	number.theme = number_theme
	number.text = text
	number.set_anchors_preset(Control.PRESET_TOP_WIDE)
	container.add_child(number)
	return container

func spawn_line(start_time, color):
	var line = line_scene.instance()
	line.color = color
	line.lineid = _next_lineid
	_next_lineid += 1
	line.start_time = start_time
	line.connect("step_hit", self, "_on_step_hit")
	add_child(line)
	line.set_height(rows)

func _on_step_hit(step, lineid):
	for block in _blocks:
		if block.start_step <= step and step < block.stop_step:
			block.activate(lineid)
		if block.stop_step <= step:
			block.deactivate(lineid)

func register_block(block) -> bool:
	if snap_block(block):
		_blocks.append(block)
		return true
	else:
		return false

func unregister_block(block):
	_blocks.erase(block)
	block.deactivate_all()

func snap_block(block) -> bool:
	block.row = round(-block.position.y as float / row_height) - 1
	block.start_step = round(block.position.x as float / step_width)
	block.stop_step = block.start_step + block.duration / step_duration

	# TODO: check bounds, unset *_step if out of bounds
	if block.row < 0 or block.row >= rows:
		return false
	if block.start_step < 0 or block.stop_step > steps:
		return false

	block.position.x = block.start_step * step_width
	block.position.y = -(block.row + 1) * row_height
	return true
