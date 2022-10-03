extends Node

func _ready():
	var effect = AudioServer.get_bus_effect_instance(1, 0)

func switch_level(name: String):
	get_node("/root/Game").load_level_soon(name)

func start(_start_time: int):
	pass
