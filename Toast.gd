extends PopupPanel

var text

func _ready():
	$Label.text = text
	popup()
	yield(get_tree().create_timer(5, false), "timeout")
	queue_free()
