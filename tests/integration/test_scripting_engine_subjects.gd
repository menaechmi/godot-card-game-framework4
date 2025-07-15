extends "res://tests/UTcommon.gd"

class TestSubjectTarget:
	extends "res://tests/ScEng_common.gd"

	func test_subject_target():
		table_move(card, Vector2(100,200))
		card.scripts = {"manual": {"board": [
				{"name": "rotate_card",
				"subject": "target",
				"degrees": 270},
				{"name": "rotate_card",
				"subject": "target",
				"degrees": 90}
				]}}
		#We execute the scripts async, and then wait for targeting to finish
		card.execute_scripts()
		await target_card(card, card)
		var tween = card._tween.get_ref() as Tween
		if tween:
			await wait_for_signal(tween.finished, 0.4)
		assert_eq(card.card_rotation, 270,
				"First rotation should happen before targetting second time")
		await wait_frames(60)
		target_card(card, card)
		tween = card._tween.get_ref() as Tween
		if tween:
			await wait_for_signal(tween.finished, 0.4)
		assert_eq(card.card_rotation, 90,
				"Second rotation should also happen")

class TestSubjectBoardseek:
	extends "res://tests/ScEng_common.gd"
	func _init() -> void:
		target_index = 1

	func test_subject_boardseek():
		var target2: Card = cards[2]
		var ttype : String = target.properties["Type"]
		var ttype2 : String = target2.properties["Type"]
		table_move(target, Vector2(500,200))
		table_move(cards[2], Vector2(800,200))
		card.scripts = {"manual": {"hand": [
				{"name": "rotate_card",
				"subject": "boardseek",
				"subject_count": "all",
				"filter_state_seek": [{"filter_properties":  {"Type": ttype}}],
				"degrees": 180},
				{"name": "rotate_card",
				"subject": "boardseek",
				"subject_count": "all",
				"filter_state_seek": [{"filter_properties": {"Type": ttype2}}],
				"degrees": 90}]}}
	# warning-ignore:unused_variable
		await card.execute_scripts()
		var tween = target._tween.get_ref() as Tween
		if tween:
			await wait_for_signal(tween.finished, 1)
		else:
			await wait_frames(20)
		assert_eq(target.card_rotation, 180,
				"Card on board matching property should be rotated 90 degrees")
		assert_eq(target2.card_rotation, 90,
				"Card on board matching property should be rotated 180 degrees")

class TestSubjectPrevious:
	extends "res://tests/ScEng_common.gd"

	func test_subject_previous():
		target = cfc.NMAP.deck.get_card(1)
		card.scripts = {"manual": {"hand": [
				{"name": "move_card_to_board",
				"subject": "index",
				"subject_index": 1,
				"src_container": "deck",
				"board_position":  Vector2(1000,200)},
				{"name": "flip_card",
				"subject": "previous",
				"set_faceup": true},
				{"name": "rotate_card",
				"subject": "previous",
				"degrees": 90}]}}
		await card.execute_scripts()
		var tween = target._tween.get_ref() as Tween
		if tween:
			await wait_for_signal(tween.finished, 0.5)
		assert_eq(target.card_rotation, 90,
				"Target should be pre-selected to be rotated")
		assert_true(target.is_faceup,
				"Target should be pre-selected to be flipped")
		pending("Test:" + SP.KEY_FILTER_EACH_REVIOUS_SUBJECT)


	func test_subject_boardseek_previous():
		var target2: Card = cards[2]
		@warning_ignore("unused_variable")
		var ttype : String = target.properties["Type"]
		table_move(target, Vector2(500,200))
		table_move(cards[2], Vector2(800,200))
		card.scripts = {"manual": {"hand": [
				{"name": "rotate_card",
				"subject": "boardseek",
				"subject_count": "all",
				"filter_state_seek": [{"filter_properties": {"Tags": "Tag 1"}}],
				"degrees": 90},
				{"name": "flip_card",
				"subject": "previous",
				"set_faceup": false}]}}
	# warning-ignore:unused_variable
		await card.execute_scripts()
		var tween = target._tween.get_ref() as Tween
		if tween:
			await wait_for_signal(tween.finished, 2)
		assert_false(target.is_faceup,
				"Target should be pre-selected to be flipped")
		assert_false(target2.is_faceup,
				"Target2 should be pre-selected to be flipped")

class TestSubjectTutor:
	extends "res://tests/ScEng_common.gd"

	func test_subject_tutor():
		card.scripts = {"manual": {"hand": [
				{"name": "move_card_to_board",
				"subject": "tutor",
				"src_container": "deck",
				"filter_state_tutor": [{"filter_properties": {"Type": "Red"}}],
				"board_position":  Vector2(1000,200)}]}}
		card.execute_scripts()
		target = cfc.NMAP.board.get_card(0)
		var tween = target._tween.get_ref() as Tween
		if tween:
			await wait_for_signal(tween.finished, 0.5)
		assert_eq("Red",target.properties["Type"],
				"Card of the correct type should be placed on the board")
		card.scripts = {"manual": {"hand": [
				{"name": "move_card_to_board",
				"subject": "tutor",
				"src_container": "deck",
				"filter_state_tutor": [{"filter_properties":
					{"Name": "Multiple Choices Test Card"}}],
				"board_position":  Vector2(100,200)}]}}
		card.execute_scripts()
		target = cfc.NMAP.board.get_card(1)
		tween = target._tween.get_ref() as Tween
		if tween:
			await wait_for_signal(tween.finished, 0.5)
		assert_eq("Multiple Choices Test Card",target.canonical_name,
				"Card of the correct name should be placed on the board")

class TestSubjectIndex:
	extends "res://tests/ScEng_common.gd"

	func test_subject_index():
		target = cfc.NMAP.deck.get_card(5)
		card.scripts = {"manual": {"hand": [
				{"name": "move_card_to_board",
				"subject": "index",
				"subject_index": 5,
				"src_container": "deck",
				"board_position":  Vector2(1000,200)}]}}
		card.execute_scripts()
		var tween = target._tween.get_ref() as Tween
		if tween:
			await wait_for_signal(tween.finished, 0.5)
		assert_eq(cfc.NMAP.board,target.get_parent(),
				"Card should have moved to board")
		target = cfc.NMAP.deck.get_card(0)
		card.scripts = {"manual": {"hand": [
				{"name": "move_card_to_board",
				"subject": "index",
				"src_container": "deck",
				"board_position":  Vector2(100,200)}]}}
		card.execute_scripts()
		tween = target._tween.get_ref() as Tween
		if tween:
			await wait_for_signal(tween.finished, 0.5)
		assert_eq(cfc.NMAP.board,target.get_parent(),
				"When index is not specified, top card should have moved to the board")

class TestSubjectPreviousWithFilters:
	extends "res://tests/ScEng_common.gd"

	func test_subject_previous_with_filters():
		target = cfc.NMAP.deck.get_card(1)
		# Flip-Down a Purple card to get 1 research.
		# Flip-Down a Red card to get 2 research.
		card.scripts = {"manual": {
					"hand":[
						{
							"name": "flip_card",
							"set_faceup": false,
							"subject": "target",
							"is_cost": true,
							"filter_state_subject": [
								{"filter_properties1": {"Type": "Purple"}},
								{"filter_properties1": {"Type": "Red"}},
							],
						},
						{
							"name": "mod_counter",
							"counter_name": "research",
							"modification": 1,
							"subject": "previous",
							"filter_state_subject": [
								{"filter_properties": {"Type": "Purple"}},
							],
						},
						{
							"name": "mod_counter",
							"counter_name": "research",
							"modification": 2,
							"subject": "previous",
							"filter_state_subject": [{
								"filter_properties": {"Type": "Red"},
							}],
						},
					],
				},
			}
		card._debugger_hook = true
		await execute_with_target(card,cards[2])
		await wait_seconds(0.3) 
		assert_eq(board.counters.get_counter("research"),2,
				"Counter increased by specified amount")
		await execute_with_target(card,cards[4])
		await wait_seconds(0.3) 
		assert_eq(board.counters.get_counter("research"),3,
				"Counter increased by specified amount")

class TestSubjectsNext:
	extends "res://tests/ScEng_common.gd"

	# Tests that a card subject can grab from the next
	# As long as the targeting is_cost
	func test_subject_next():
		card.scripts = {
				"manual": {
					"hand":[
						# This has to go before the move, or the check for
						# the parent will happen after the card is already
						# in the discard pile
						{
							"name": "mod_counter",
							"counter_name": "research",
							"modification": 3,
							"subject": "previous",
							"filter_state_subject": [
								{"filter_parent": "hand"},
							],
						},
						{
							"name": "move_card_to_container",
							"dest_container": "discard",
							"subject": "target",
							"is_cost": true,
						},
					],
				},
			}
		await execute_with_target(card,target)
		var tween = target._tween.get_ref() as Tween
		if tween:
			await wait_for_signal(tween.finished, 0.5)
		assert_eq(board.counters.get_counter("research"),3,
				"Counter set to the specified amount")

