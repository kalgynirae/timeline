extends KinematicBody2D

const GRAVITY = 400.0
const H_SPEED = 200.0
const JUMP_SPEED = 300
var velocity = Vector2()

var movingLeft = 0
var movingRight = 0

func _enter_tree():
	if get_node("/root/Game").thymefred:
		$Thymefred.visible = true
		$Sprite.visible = false

func _physics_process(delta):
	velocity.y += delta * GRAVITY
	var velocity_adj = velocity
	if movingLeft:
		velocity_adj.x -= H_SPEED
	if movingRight:
		velocity_adj.x += H_SPEED
	if velocity_adj.x > H_SPEED:
		velocity_adj.x = H_SPEED
	if velocity_adj.x < -H_SPEED:
		velocity_adj.x = -H_SPEED

	var motion = velocity_adj * delta
	var collision = move_and_collide(motion, false, true, true)
	if not collision == null:
		# Cancel out velocity in the collision direction
		var angle = collision.get_angle()
		var col_dir = Vector2(-sin(angle), cos(angle)).normalized()
#		print(col_dir)
		velocity_adj -= velocity_adj.dot(col_dir) * col_dir * 1.0
		if col_dir.y > 0.8:
			velocity.y = 0
#		print(velocity)
		motion = velocity_adj * delta
	move_and_collide(motion, false)

func _input(event):
	if Input.is_action_pressed("ui_up"):
		Jump()


func Jump():
	if move_and_collide(Vector2(0,2), false, true, true):
		velocity.y = -JUMP_SPEED

func StartMoveLeft():
	movingLeft += 1

func StopMoveLeft():
	movingLeft -= 1

func StartMoveRight():
	movingRight += 1

func StopMoveRight():
	movingRight -= 1

