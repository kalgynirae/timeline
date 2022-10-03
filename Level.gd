extends Node

func switch_level(name: String):
	get_node("/root/Game").load_level_soon(name)

func start(_start_time: int):
	pass
