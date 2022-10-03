extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var max_y = 500
export var min_y = 100
export var max_x = 1180
export var min_x = 100

export var start_x = 100
export var start_y = 100

export var speed_x = 1.0
export var speed_y = 1.0

var closed = false
var actuating = false

const SPEED_SCALE = 140
const VT_OFFSET = -10

# Called when the node enters the scene tree for the first time.
func _ready():
#	$Claw_body.position = Vector2(start_x, start_y)
	$Claw_body.position.x = start_x
	$Claw_body.position.y = start_y

	UpdateGraphics()



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func UpdateGraphics():
	var x = $Claw_body.position.x
	var y = $Claw_body.position.y

	$VerticalTrack.scale.y = y
	$VerticalTrack.position.x = x + VT_OFFSET

func MoveUp(delta):
	var new_y = $Claw_body.position.y - speed_y * delta * SPEED_SCALE
	if new_y < min_y:
		new_y = min_y
	$Claw_body.position.y = new_y
	UpdateGraphics()

func MoveDown(delta):
	var new_y = $Claw_body.position.y + speed_y * delta * SPEED_SCALE
	if new_y > max_y:
		new_y = max_y
	$Claw_body.position.y = new_y
	UpdateGraphics()

func MoveLeft(delta):
	var new_x = $Claw_body.position.x - speed_x * delta * SPEED_SCALE
	if new_x < min_x:
		new_x = min_x
	$Claw_body.position.x = new_x
	UpdateGraphics()

func MoveRight(delta):
	var new_x = $Claw_body.position.x + speed_x * delta * SPEED_SCALE
	if new_x > max_x:
		new_x = max_x
	$Claw_body.position.x = new_x
	UpdateGraphics()

func Close():
	if not closed and not actuating:
		actuating = true
		$Claw_body/AnimationPlayer.play("Close")
		yield($Claw_body/AnimationPlayer, "animation_finished")
		actuating = false
		closed = true

func Open():
	if closed and not actuating:
		actuating = true
		$Claw_body/AnimationPlayer.play_backwards("Close")
		yield($Claw_body/AnimationPlayer, "animation_finished")
		actuating = false
		closed = false
