extends Area2D

export var what_next = "Title"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", self, "_level_done")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _level_done(body):
	if body.get_name() == "Timefred":
		print("Yay " + body.get_name() + "!")
		get_node("/root/Game").load_level_soon(what_next)


