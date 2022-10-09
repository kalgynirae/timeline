extends Node2D

export var rows = 5
export var locked_rows = 1

var step_width = 25
var row_height = 50

var line_start_position = Vector2(100, -311)
var step_duration = 250
var steps = 40
var primary_every = 4

var LockIcon = preload("res://LockIcon.tscn")
var Line = preload("res://Line.tscn")
var number_theme = load("res://TimelineNumbers.tres")

var _blocks = []
var _lineids = {}
var _next_lineid = 1
var _show_restart_after
var _showed_restart = false

func _ready():
	generate()

func _input(event):
	if event is InputEventMouseMotion:
		if event.button_mask & BUTTON_MASK_MIDDLE:
			position = event.position
	elif event is InputEventMouseButton and event.pressed:
		if event.shift:
			match event.button_index:
				BUTTON_WHEEL_UP:
					locked_rows = clamp(locked_rows + 1, 0, rows)
				BUTTON_WHEEL_DOWN:
					locked_rows = clamp(locked_rows - 1, 0, rows)
		else:
			match event.button_index:
				BUTTON_WHEEL_UP:
					step_width += 5
				BUTTON_WHEEL_DOWN:
					step_width -= 5
		generate()
	elif Input.is_action_pressed("pause"):
		print("not implemented yet!")
	elif Input.is_action_pressed("spawn_line"):
		spawn_line(Color("00ff00"))

func _process(_delta):
	if not _lineids.empty() and _show_restart_after != null:
		_show_restart_after = null
	if _lineids.empty() and _show_restart_after == null:
		_show_restart_after = Time.get_ticks_msec() + 500
	if _show_restart_after != null and Time.get_ticks_msec() >= _show_restart_after:
		show_restart()

func clear():
	for node in $verticals.get_children():
		node.queue_free()
	for node in $horizontals.get_children():
		node.queue_free()
	for node in $numbers.get_children():
		node.queue_free()
	for node in $subverticals.get_children():
		node.queue_free()
	for node in $locks.get_children():
		node.queue_free()
	$Restart.visible = false

func generate():
	clear()
	var height = rows * row_height
	var width = steps * step_width
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
	for row in range(locked_rows):
		$locks.add_child(lock_icon(row))
		$locks.add_child(lock_overlay(row))
	$Restart.position = Vector2(width / 2, -height - 35)
	for block in _blocks:
		resize_block(block)
		maybe_lock_block(block)

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

func lock_icon(row):
	var icon = LockIcon.instance()
	icon.position.x = -25 * sign(step_width)
	icon.position.y = -(row+1) * row_height
	return icon

func lock_overlay(row):
	var overlay = Polygon2D.new()
	overlay.polygon = [
		Vector2(0, -(row+1)*row_height),
		Vector2(0, -row*row_height),
		Vector2(step_width*steps, -row*row_height),
		Vector2(step_width*steps, -(row+1)*row_height),
	]
	overlay.color = Color("60000000")
	overlay.z_index = 1
	return overlay

func _spawn_line(color, dark: bool):
	var line = Line.instance()
	line.color = color
	line.dark = dark
	line.lineid = _next_lineid
	_next_lineid += 1
	line.connect("step_hit", self, "_on_step_hit")
	line.connect("vanish", self, "_on_line_vanish")
	add_child(line)
	line.set_height(rows)
	_lineids[line.lineid] = true

func spawn_line(color):
	_spawn_line(color, false)

func spawn_dark_line():
	_spawn_line(Color("000000"), true)

func _on_step_hit(step, lineid, dark):
	for block in _blocks:
		if block.start_step <= step and step < block.stop_step and block.dark == dark:
			block.activate(lineid)
		if block.stop_step <= step and block.dark == dark:
			block.deactivate(lineid)

func _on_line_vanish(lineid, dark):
	for block in _blocks:
		if block.dark == dark:
			block.deactivate(lineid)
	_lineids.erase(lineid)

func register_block(block, initial_placement: bool):
	if snap_block(block, initial_placement):
		_blocks.append(block)
	else:
		block.disable()

func unregister_block(block):
	_blocks.erase(block)
	block.deactivate_all()
	block.reset()

func snap_block(block, initial_placement: bool) -> bool:
	block.row = round(-block.position.y as float / row_height) - 1
	block.start_step = round(block.position.x as float / step_width)
	block.stop_step = block.start_step + block.duration / step_duration

	var in_locked_row = block.row < locked_rows
	var in_timeline = not (
		block.row >= rows
		or block.start_step < 0
		or block.stop_step > steps
	)

	if (in_timeline and not in_locked_row) or initial_placement:
		resize_block(block)
		maybe_lock_block(block)
	return in_timeline and (not in_locked_row or initial_placement)

func resize_block(block):
	block.position.x = block.start_step * step_width
	block.position.y = -(block.row + 1) * row_height
	block.resize()

func maybe_lock_block(block):
	if block.row < locked_rows:
		block.lock()
	else:
		block.unlock()

func lock():
	locked_rows = rows
	generate()

func show_restart():
	if _showed_restart:
		return
	_showed_restart = true
	$Restart.modulate = Color("00ffffff")
	$Restart.visible = true
	var tween = create_tween()
	tween.tween_property($Restart, "modulate", Color("ffffffff"), 1.0).set_trans(Tween.TRANS_QUAD)
