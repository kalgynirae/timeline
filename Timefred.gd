extends KinematicBody2D

const GRAVITY = 200.0
var velocity = Vector2()

var movingLeft = false
var movingRight = true

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	velocity.y += delta * GRAVITY
	
	if movingLeft:
		velocity.x = -100
	
	var motion = velocity * delta
	var collision = move_and_collide(motion, false, true, true)
	if not collision == null:
		velocity = Vector2(0,0)
		var angle = collision.get_angle()
		var col_dir = Vector2(sin(angle), cos(angle)).normalized()
		velocity -= velocity.dot(col_dir) * velocity
		motion = velocity * delta
	move_and_collide(motion, false)

func _input(event):
	if Input.is_action_pressed("ui_up"):
		Jump()


func Jump():
	if move_and_collide(Vector2(0,1), false, true, true):
		velocity.y = -200

func StartMoveLeft():
	movingLeft = true
	
func StopMoveLeft():
	movingLeft = false
	
func StartMoveRight():
	movingRight = true
	
func StopMoveRight():
	movingRight = false
	

	
