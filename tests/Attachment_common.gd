extends "res://tests/Basic_common.gd"

func before_each():
	await super.before_each()
	board.get_node("EnableAttach").button_pressed = true
	await wait_seconds(0.1)
