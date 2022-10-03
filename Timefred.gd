extends KinematicBody2D

const GRAVITY = 200.0
var velocity = Vector2()

var movingLeft = false
var movingRight = false

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
	var velocity_adj = velocity
	if movingLeft:
		velocity_adj.x -= 100
	if movingRight:
		velocity_adj.x += 100
	if velocity_adj.x > 100:
		velocity_adj.x = 100
	if velocity_adj.x < -100:
		velocity_adj.x = -100
	
	var motion = velocity_adj * delta
	var collision = move_and_collide(motion, false, true, true)
	if not collision == null:
		# Cancel out velocity in the collision direction
		var angle = collision.get_angle()
		var col_dir = Vector2(-sin(angle), cos(angle)).normalized()
#		print(col_dir)
		velocity_adj -= velocity_adj.dot(col_dir) * col_dir
		if col_dir.y > 0:
			velocity.y = 0
#		print(velocity)
		motion = velocity_adj * delta
	move_and_collide(motion, false)

func _input(event):
	if Input.is_action_pressed("ui_up"):
		Jump()


func Jump():
	if move_and_collide(Vector2(0,2), false, true, true):
		velocity.y = -150

func StartMoveLeft():
	movingLeft = true
	
func StopMoveLeft():
	movingLeft = false
	
func StartMoveRight():
	movingRight = true
	
func StopMoveRight():
	movingRight = false
	

	
