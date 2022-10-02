extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var max_y = 500
export var min_y = 100
export var max_x = 100
export var min_x = 1180

export var start_x = 100
export var start_y = 100

export var speed = 2

var isClosed = false

const VT_OFFSET = -15

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
	
	
func MoveDown():
	$Claw_body.position.y += speed
	UpdateGraphics()
