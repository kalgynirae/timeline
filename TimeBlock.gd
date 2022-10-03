extends Node2D

export var type: String
export var duration: int
export var dark: bool
export var dingly: bool

const COLORS = {
	"_default": Color("808080"),
	"start": Color("00c000"),
	"quit": Color("c00000"),
	"spawn_line": Color("606060"),
	"lock": Color("606060"),
	"claw_up": Color("3080f0"),
	"claw_down": Color("5080f0"),
	"claw_left": Color("7080f0"),
	"claw_right": Color("9080f0"),
	"claw_open": Color("37d67a"),
	"claw_close": Color("e91e63"),
	"tf_left": Color("37d67a"),
	"tf_right": Color("e91e63"),
	"tf_jump": Color("9080f0")
}

var active = false
var row
var start_step
var stop_step

var _activated_by = {}
var _audio_volume
var _grabbed = false
var _grab_offset
var _locked = false
var _timeline

func _enter_tree():
	_timeline = get_node("%Timeline")
	if not _timeline.register_block(self, true):
		$AnimationPlayer.play("disabled")
	deactivate_all()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed and not _locked:
			if not _grabbed and $ColorRect.get_global_rect().has_point(event.position):
				grab(event.position)
			elif _grabbed:
				ungrab()
	if event is InputEventMouseMotion and _grabbed:
		global_position = event.position - _grab_offset
		_timeline.snap_block(self, false)

func _ready():
	if _audio_volume == null:
		_audio_volume = $ActiveSound.volume_db
	resize()
	$ColorRect/Label.text = type
	$ColorRect.color = COLORS.get(type, COLORS["_default"])
	$Particles.process_material = $Particles.process_material.duplicate()
	$Particles.process_material.color = COLORS.get(type, COLORS["_default"]).lightened(0.3)
	$Particles.process_material.color.a = 0.75
	$DarkParticles.process_material = $DarkParticles.process_material.duplicate()
	if dark:
		$DarkParticles.emitting = true

	match type:
		"lock":
			$ColorRect/Label.text = ""
			$ColorRect/LockIcon.visible = true
		"spawn_line":
			$ColorRect/Label.text = ""
			$ColorRect/LineIcon.visible = true

func _process(delta):
	if active:
		match type:
			"claw_up":
				get_node("%Claw").MoveUp()
			"claw_down":
				get_node("%Claw").MoveDown()
			"claw_left":
				get_node("%Claw").MoveLeft()
			"claw_right":
				get_node("%Claw").MoveRight()

func resize():
	var size_x = duration as float / _timeline.step_duration * _timeline.step_width
	$ColorRect.rect_size.x = abs(size_x)
	if size_x < 0:
		position.x += size_x
	$Particles.amount = $ColorRect.rect_size.x
	$Particles.position = $ColorRect.rect_size / 2
	$Particles.process_material.emission_box_extents.x = max($ColorRect.rect_size.x / 2 - 5, 5)
	$DarkParticles.amount = $ColorRect.rect_size.x / 4
	$DarkParticles.position = $ColorRect.rect_size / 2
	$DarkParticles.process_material.emission_box_extents.x = max($ColorRect.rect_size.x / 2 - 5, 5)
	$ColorRect/LockIcon.position.x = $ColorRect.rect_size.x / 2
	$ColorRect/LineIcon.position.x = $ColorRect.rect_size.x / 2

func activate(lineid):
	if _activated_by.empty():
		active = true
		$ColorRect.modulate = Color("ffffff")
		$Particles.emitting = true
		var sound = $ActiveSoundDingly if dingly else $ActiveSound
		sound.volume_db = -9.0
		sound.play()
		match type:
			"show_devs":
				get_node("%DevsText").show()
			"lock":
				_timeline.lock()
			"spawn_line":
				_timeline.spawn_line(Color("00ff00"))
			"claw_open":
				get_node("%Claw").Open()
			"claw_close":
				get_node("%Claw").Close()
			"tf_left":
				get_node("%Timefred").StartMoveLeft()
			"tf_right":
				get_node("%Timefred").StartMoveRight()
	_activated_by[lineid] = true

func deactivate(lineid):
	_activated_by.erase(lineid)
	$ColorRect.modulate = Color("d0d0d0")
	$Particles.emitting = false

	if _activated_by.empty() and active:
		active = false
		match type:
			"quit":
				get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
			"start":
				get_node("/root/Game").emit_signal("load_level", "Tutorial")
			"tf_left":
				get_node("%Timefred").StopMoveLeft()
			"tf_right":
				get_node("%Timefred").StopMoveRight()

	var sound = $ActiveSoundDingly if dingly else $ActiveSound
	if sound.playing:
		var tween = create_tween()
		tween.tween_property(sound, "volume_db", -20.0, 0.4)
		yield(tween, "finished")
		sound.stop()
		sound.volume_db = _audio_volume

func deactivate_all():
	_activated_by.clear()
	deactivate(0)

func grab(mouse_position):
	_grabbed = true
	_grab_offset = mouse_position - global_position
	_timeline.unregister_block(self)
	$AnimationPlayer.play("blink")

func ungrab():
	_grabbed = false
	if _timeline.register_block(self, false):
		$AnimationPlayer.play("RESET")
	else:
		$AnimationPlayer.play("disabled")

func lock():
	_locked = true

func unlock():
	_locked = false
