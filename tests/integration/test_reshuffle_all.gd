extends "res://tests/UTcommon.gd"

var cards := []
#This doesn't seem like it actually tests shuffling, but it's also a custom-only function
func before_each():
	await setup_board()
	cards = await draw_test_cards(5)
	await wait_seconds(1)

func after_each():
	cfc.game_settings.fancy_movement = true

func test_fancy_reshuffle_all():
	cfc.game_settings.fancy_movement = true
	await drag_drop(cards[0], Vector2(300,300))
	await drag_drop(cards[4], Vector2(1000,10))
	board.reshuffle_all_in_pile()
	await wait_frames(21)
	#Added drag_drop offset
	assert_almost_eq(cards[0].global_position, Vector2(320, 300), Vector2(10,10), 
			"Card is not being teleported from where is expect by Tween")
	assert_almost_eq(cards[4].global_position, Vector2(1020, 10), Vector2(10,10), 
			"Card is not being teleported from where is expect by Tween")
	var tween = cards[4]._tween.get_ref() as Tween
	if tween:
		await wait_for_signal(tween.finished, 1)

func test_basic_reshuffle_all():
	cfc.game_settings.fancy_movement = false
	await drag_drop(cards[0], Vector2(300,300))
	await drag_drop(cards[4], Vector2(1000,10))
	board.reshuffle_all_in_pile()
	await wait_frames(21)
	#Added drag_drop offset
	assert_almost_eq(cards[0].global_position, Vector2(320, 300), Vector2(10,10), 
			"Card is not being teleported from where is expected by Tween")
	assert_almost_eq(cards[4].global_position, Vector2(1020, 10), Vector2(10,10), 
			"Card is not being teleported from where is expected by Tween")
	var tween = cards[4]._tween.get_ref() as Tween
	if tween:
		await wait_for_signal(tween.finished, 1)
