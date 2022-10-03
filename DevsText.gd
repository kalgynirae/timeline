extends Sprite

func show():
	modulate = Color("00ffffff")
	visible = true
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color("ffffffff"), 1.5).set_trans(Tween.TRANS_QUAD)
