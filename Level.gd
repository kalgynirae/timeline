extends Node

export var next_level: String

func switch_level(name: String):
	get_node("/root/Game").load_level_soon(name)

func start(_start_time: int):
	pass
