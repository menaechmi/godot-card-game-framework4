extends "res://tests/UTcommon.gd"

var cards := []

func before_each():
	await setup_board()
	cards = await draw_test_cards(5)
	await wait_seconds(0.1)
