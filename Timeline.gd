extends Node2D

var colwidth = 100
var rowheight = 50

var line_start_position = Vector2(100, -311)
var step_duration = 1_000
var steps = 10

var line_scene = preload("res://Line.tscn")
var number_theme = load("res://TimelineNumbers.tres")

func _ready():
	generate(5)

func _input(event):
	if event is InputEventMouseMotion:
		if event.button_mask & BUTTON_LEFT:
			position = event.position
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			colwidth += 5
			generate(5)
		if event.button_index == BUTTON_WHEEL_DOWN:
			colwidth -= 5
			generate(5)

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

func generate(rows):
	clear()
	var height = rows * rowheight
	for i in range(11):
		var line
		if i == 0 or i == 10:
			line = vertical(i*colwidth, height, 8)
		else:
			line = vertical(i*colwidth, height, 4)
		line.name = "vertical" + i as String
		$verticals.add_child(line)
		$numbers.add_child(number(i*colwidth, i as String))
	for i in range(10):
		$subverticals.add_child(vertical(i*colwidth + colwidth / 2, height, 1))
	for i in range(rows+1):
		$horizontals.add_child(horizontal(-i*rowheight, 10*colwidth, 2))

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
	container.rect_position = Vector2(x - abs(colwidth / 2), - (rowheight / 10))
	container.rect_size = Vector2(abs(colwidth), rowheight)
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
	line.start_time = start_time
	line.connect("step_hit", self, "_on_step_hit")
	add_child(line)

func _on_step_hit(step, _color):
	print("step hit: ", step)
	var line = get_node("verticals/vertical" + step as String)
	var orig = line.width
	line.width = 20
	yield(get_tree().create_timer(0.1), "timeout")
	line.width = orig
