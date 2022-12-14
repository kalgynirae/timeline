extends Node2D

export var type: String
export var duration: int
export var dark: bool
export var dingly: bool

const COLORS = {
	"_default": Color("808080"),
	"start": Color("00c000"),
	"proceed": Color("00c000"),
	"quit": Color("c00000"),
	"spawn_line": Color("606060"),
	"lock": Color("606060"),
	"claw_up": Color("ffffff"),
	"claw_down": Color("ffffff"),
	"claw_left": Color("ffffff"),
	"claw_right": Color("ffffff"),
	"claw_open": Color("7080f0"),
	"claw_close": Color("7080f0"),
	"tf_left": Color("ff4040"),
	"tf_right": Color("ff4040"),
	"tf_jump": Color("ff4040"),
	"blink": Color("c0c000"),
	"show_text": Color("00c0c0")
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
	_timeline.register_block(self, true)

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
		"claw_left", "tf_left":
			$ColorRect/Label.text = ""
			$ColorRect/LeftIcon.visible = true
		"claw_right", "tf_right":
			$ColorRect/Label.text = ""
			$ColorRect/RightIcon.visible = true
		"claw_up", "tf_jump":
			$ColorRect/Label.text = ""
			$ColorRect/UpIcon.visible = true
		"claw_down":
			$ColorRect/Label.text = ""
			$ColorRect/DownIcon.visible = true

func _physics_process(delta):
	if active:
		match type:
			"claw_up":
				get_node("%Claw").MoveUp(delta)
			"claw_down":
				get_node("%Claw").MoveDown(delta)
			"claw_left":
				get_node("%Claw").MoveLeft(delta)
			"claw_right":
				get_node("%Claw").MoveRight(delta)

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
	$ColorRect/LeftIcon.position.x = $ColorRect.rect_size.x / 2
	$ColorRect/RightIcon.position.x = $ColorRect.rect_size.x / 2
	$ColorRect/UpIcon.position.x = $ColorRect.rect_size.x / 2
	$ColorRect/DownIcon.position.x = $ColorRect.rect_size.x / 2

func activate(lineid):
	if _activated_by.empty():
		active = true
		$ColorRect.modulate = Color("ffffff")
		$Particles.emitting = true
		var sound = $ActiveSoundDingly if dingly else $ActiveSound
		sound.volume_db = -9.0
		sound.play()
		match type:
			"quit":
				get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
			"start":
				get_node("/root/Game").load_level_soon("PreTutorial")
			"proceed":
				get_node("/root/Game").load_next_level_soon()
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
			"tf_jump":
				get_node("%Timefred").Jump()
			"blink":
				get_node("%Clock").visible = true
			"show_text":
				var text
				if get_node("/root/Game").thymefred:
					text = get_node("%TextThyme")
				else:
					text = get_node("%Text")
				text.modulate = Color("00ffffff")
				text.visible = true
				var tween = create_tween()
				tween.tween_property(text, "modulate", Color("ffffffff"), 1.0).set_trans(Tween.TRANS_QUAD)
			"show_text_2":
				var text = get_node("%Text2")
				text.modulate = Color("00ffffff")
				text.visible = true
				var tween = create_tween()
				tween.tween_property(text, "modulate", Color("ffffffff"), 1.0).set_trans(Tween.TRANS_QUAD)
			"show_text_3":
				var text = get_node("%Text3")
				text.modulate = Color("00ffffff")
				text.visible = true
				var tween = create_tween()
				tween.tween_property(text, "modulate", Color("ffffffff"), 1.0).set_trans(Tween.TRANS_QUAD)
	_activated_by[lineid] = true

func deactivate(lineid):
	_activated_by.erase(lineid)
	if _activated_by.empty() and active:
		active = false
		$ColorRect.modulate = Color("d0d0d0")
		$Particles.emitting = false

		match type:
			"show_devs":
				get_node("%DevsText").hide()
			"tf_left":
				get_node("%Timefred").StopMoveLeft()
			"tf_right":
				get_node("%Timefred").StopMoveRight()
			"blink":
				get_node("%Clock").visible = false
			"show_text":
				var text
				if get_node("/root/Game").thymefred:
					text = get_node("%TextThyme")
				else:
					text = get_node("%Text")
				var tween = create_tween()
				tween.tween_property(text, "modulate", Color("00ffffff"), 0.7).set_trans(Tween.TRANS_QUAD)
			"show_text_2":
				var text = get_node("%Text2")
				var tween = create_tween()
				tween.tween_property(text, "modulate", Color("00ffffff"), 0.7).set_trans(Tween.TRANS_QUAD)
			"show_text_3":
				var text = get_node("%Text3")
				var tween = create_tween()
				tween.tween_property(text, "modulate", Color("00ffffff"), 2.0).set_trans(Tween.TRANS_QUAD)

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
	reset()
	_timeline.register_block(self, false)

func lock():
	_locked = true

func unlock():
	_locked = false

func disable():
	$AnimationPlayer.play("disabled")

func reset():
	$AnimationPlayer.play("RESET")
