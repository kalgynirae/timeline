extends Node2D

var _popup_shown = false

var Toast = preload("res://Toast.tscn")

func _ready():
	load_level("TestC")

func _input(event):
	if event is InputEventKey and event.pressed and event.scancode == KEY_ENTER:
		if _popup_shown:
			$InputPanel.hide()
			_popup_shown = false
		else:
			var coro = show_popup("Level name")
			var name = yield(coro, "completed")
			load_level(name)

func show_popup(label):
	_popup_shown = true
	$InputPanel/HBoxContainer/Label.text = label + ": "
	$InputPanel/HBoxContainer/LineEdit.text = ""
	$InputPanel.popup_centered()
	yield($InputPanel, "popup_hide")
	return $InputPanel/HBoxContainer/LineEdit.text

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
