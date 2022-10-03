extends Node2D

signal load_level(name)

var _current_level
var _next_level = "Title"
var _popup_shown = false

var Toast = preload("res://Toast.tscn")

func _ready():
	connect("load_level", self, "load_level_soon")

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
		load_level(_current_level)
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

func load_level(name):
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
	var level = new_packed.instance()
	$CurrentLevel.add_child(level)
	level.start(Time.get_ticks_msec() + 500)
	_current_level = name
