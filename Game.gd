extends Node2D

var _current_level
var _next_level = "Title"
var _popup_shown = false
var thymefred = false

var Toast = preload("res://Toast.tscn")

func _input(event):
	if event is InputEventKey and event.pressed and event.scancode == KEY_ENTER:
		if _popup_shown:
			$InputPanel.hide()
			_popup_shown = false
		else:
			var coro = show_popup("Level name")
			var name = yield(coro, "completed")
			load_level(name)
	elif Input.is_action_pressed("restart_level"):
		if Input.is_key_pressed(KEY_SHIFT):
			load_level(_current_level)
		else:
			restart_level()
	elif Input.is_action_pressed("quit"):
		get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)

func show_popup(label):
	_popup_shown = true
	$InputPanel/HBoxContainer/Label.text = label + ": "
	$InputPanel/HBoxContainer/LineEdit.text = ""
	$InputPanel.popup_centered()
	yield($InputPanel, "popup_hide")
	return $InputPanel/HBoxContainer/LineEdit.text

func _process(_delta):
	if _next_level != null:
		load_level(_next_level)
		_next_level = null

func load_level_soon(name):
	_next_level = name

func load_next_level_soon():
	_next_level = $CurrentLevel.get_child(0).next_level
	if _next_level == "End" and thymefred:
		_next_level = "Title"

func load_level(name, start: bool = true):
	print("load_level(", name, ")")
	var new_packed = load("res://levels/" + name + ".tscn")
	if new_packed == null:
		var toast = Toast.instance()
		toast.text = "Unknown level: " + name
		add_child(toast)
		return
	for node in $CurrentLevel.get_children():
		$CurrentLevel.remove_child(node)
		node.queue_free()
	_current_level = name
	var level = new_packed.instance()
	$CurrentLevel.add_child(level)
	if start:
		level.start(Time.get_ticks_msec() + 500)
		if not $MusicPlayer.playing:
			$MusicPlayer.play()

func restart_level():
	var timeblock_positions = {}
	collect_positions(timeblock_positions, $CurrentLevel.get_child(0))
	load_level(_current_level, false)
	var level = $CurrentLevel.get_child(0)
	var timeline = level.find_node("Timeline")
	for name in timeblock_positions:
		var block = level.find_node(name)
		timeline.unregister_block(block)
		block.position = timeblock_positions[name]
		timeline.register_block(block, true)
	level.start(Time.get_ticks_msec() + 500)

func collect_positions(positions, node):
	if node.filename == "res://TimeBlock.tscn":
		positions[node.name] = node.position
	for child in node.get_children():
		collect_positions(positions, child)
