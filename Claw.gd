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

var claw_state


# Called when the node enters the scene tree for the first time.
func _ready():
#	$Claw_body.position = Vector2(start_x, start_y)
	$Claw_body.position[0] = start_x
	$Claw_body.position[1] = start_y
	
	UpdateGraphics(claw_x, claw_y)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func UpdateGraphics(x,y):
	
	var vt1 = $VerticalTrack.polygon
	var vt2 = $VerticalTrack.polygon
	
