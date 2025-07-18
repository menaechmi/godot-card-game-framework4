extends "res://tests/UTcommon.gd"

class TestMoveToContainer:
	extends "res://tests/Basic_common.gd"

	func test_move_to_container():
		var card: Card
		card = cards[2]
		#Drag_drop has trouble finding the discard
		await drag_drop(card, cfc.NMAP.discard.position)
		var tween = card._tween.get_ref() as Tween
		if tween:
			await wait_for_signal(tween.finished, 1)
		assert_almost_eq(card.global_position,cfc.NMAP.discard.position,Vector2(2,2),
				"Card's final position matches pile's position")
		assert_eq(1,cfc.NMAP.discard.get_card_count(),
				"The correct amount of cards are hosted")

	func test_move_to_multiple_container():
		await drag_drop(cards[2], cfc.NMAP.discard.position + Vector2(10,10))
		await move_mouse(Vector2(500,300))
		await drag_drop(cards[4], cfc.NMAP.deck.position + Vector2(10,10))
		await move_mouse(Vector2(500,300))
		await drag_drop(cards[1], cfc.NMAP.discard.position + Vector2(10,10))
		await move_mouse(Vector2(500,300))
		await drag_drop(cards[0], cfc.NMAP.deck.position + Vector2(10,10))
		var tween = cards[0]._tween.get_ref() as Tween
		if tween:
			await wait_for_signal(tween.finished, 1)
		assert_almost_eq(cards[2].global_position,
				cfc.NMAP.discard.global_position,Vector2(2,2),
				"Card 2 final position matches pile's position")
		assert_almost_eq(cards[1].global_position,
				cfc.NMAP.discard.global_position,Vector2(2,2),
				"Card 1 final position matches pile's position")
		assert_almost_eq(cards[4].global_position,
				cfc.NMAP.deck.position + cfc.NMAP.deck.get_stack_position(cards[4]),
				Vector2(2,2),
				"Card 3 final position matches pile's position")
		assert_almost_eq(cards[0].global_position,
				cfc.NMAP.deck.to_global(cfc.NMAP.deck.get_stack_position(cards[0])),Vector2(2,2),
				"Card 0 final position matches pile's position")
		assert_eq(2,cfc.NMAP.discard.get_card_count(),
				"Correct amount of cards are hosted in discard")
		assert_eq(14,cfc.NMAP.deck.get_card_count(),
				"Correct amount of cards are hosted in deck")
		assert_eq(1,cfc.NMAP.hand.get_card_count(),
				"Correct amount of cards are hosted in hand")

	func test_move_from_board_to_deck_to_hand():
		var card: Card
		card = cards[2]
		#Drag card to the board
		await drag_drop(card, Vector2(1000,100))
		#Drag card back to deck. The deck drop position is over further
		await drag_drop(card, cfc.NMAP.deck.position + Vector2(20,20))
		#We're waiting for the tween, but waiting for the tween causes other problems
		await wait_frames(70)
		# warning-ignore:return_value_discarded
		await hand.draw_card()
		#Wait for the right tween
		await wait_for_signal(get_tree().process_frame, 1)
		var tween = card._tween.get_ref() as Tween
		if tween:
			await wait_for_signal(tween.finished, 5)
		assert_almost_eq(card.global_position,
			hand.to_global(card.recalculate_position()),Vector2(2,2),
				"Card finished move to hand from deck from board")

class TestPileFacing:
	extends "res://tests/Basic_common.gd"

	func test_pile_facing():
		var card: Card = cfc.NMAP.deck.get_top_card()
		await card.move_to(cfc.NMAP.discard)
		var tween = card._tween.get_ref() as Tween
		if tween:
			await wait_for_signal(tween.finished, 0.5)
		assert_true(card.is_faceup, "Card should be faceup in discard")
		card = cards[0]
		await card.move_to(cfc.NMAP.deck)
		tween = card._tween.get_ref() as Tween
		if tween and tween.is_running():
			await wait_for_signal(tween.finished, 0.5)
		assert_false(card.is_faceup,"Card should be facedown in deck")

class TestPopupView:
	extends "res://tests/Basic_common.gd"

	func test_popup_discard_view():
		discard = cfc.NMAP.discard
		#This lets us change the node structure, without needing to update the tests
		var node_count := len(discard.get_children())
		var card_count := len(cfc.NMAP.deck.get_all_cards())
		for card in cfc.NMAP.deck.get_all_cards():
			await card.move_to(discard)
		await wait_seconds(1) 
		discard._on_View_Button_pressed()
		await wait_seconds(1) 
		assert_eq(len(discard.get_children()), node_count,
				"No cards should appear in the pile root after popup")
		assert_eq(discard.get_card_count(), card_count,
				"Cards in popup should be returned with get_all_cards()")
		assert_eq(discard.get_node("ViewPopup/CardView").get_child_count(), card_count,
				"All cards all migrated to popup window")
		assert_eq(discard.get_node("ViewPopup").get_theme_stylebox("panel").bg_color.a, 1.0,
				"ViewPopup should be visible")
		await cards[1].move_to(discard)
		assert_eq(discard.get_node("ViewPopup/CardView").get_child_count(), 13,
				"Hosting a card in the pile, while popup is open, puts it in the popup")
		assert_eq(cards[1].scale, Vector2(0.75,0.75),
				"Moving a card into the popup, should scale it")
		pending("Drawing a card from the pile, picks it from the popup")
		assert_false(discard.get_node("Control/ManipulationButtons").visible,
				"Manipulation Buttons should be hidden while popup is active")
		discard.get_node("ViewPopup").hide()
		await wait_seconds(1) 
		assert_true(cards[1].is_faceup,
				"Cards returning from popup should respect piles card facing")

	func test_popup_deck_view():
		deck = cfc.NMAP.deck
		var card: Card = deck.get_top_card()
		deck._on_View_Button_pressed()
		#This prevents a "p_elem->_root" error by waiting for children to be removed
		await wait_for_signal(get_tree().process_frame, 0.5)
		await wait_frames(30)
		await card.move_to(deck)
		assert_eq(Vector2(0,0),card.position,
				"Moving card from popup back to the same pile, should do nothing")
		assert_eq(Vector2(0.75,0.75),card.scale,
				"Moving card from popup back to the same pile, should do nothing")
		assert_true(card.is_faceup,
				"Moving card from popup back to the same pile, should do nothing")
		#deck.get_node("ViewPopup").hide()
		await deck._on_ViewPopup_popup_hide()
		#await wait_for_signal(deck.popup_closed, 5)
		await wait_for_signal(get_tree().process_frame, 5)
		await wait_frames(120)
		#TODO: This fails because you can't currently move piles from popups
		assert_eq(card.is_faceup, deck.faceup_cards,
				"Cards returning from popup should respect piles card facing")

class TestStacking:
	extends "res://tests/Basic_common.gd"

	func test_stacking():
		#This test fails in Run All, but works alone and in test_piles.gd?
		deck = cfc.NMAP.deck
		var card: Card = cards[4]
		await card.move_to(deck)
		var tween = card._tween.get_ref() as Tween
		if tween:
			await wait_for_signal(tween.finished, 0.5)
		else:
			await wait_frames(45)
		assert_eq(card.position,deck.get_stack_position(card),
				"Card moved in, placed in stack position")
		card = cards[2]
		await card.move_to(deck)
		tween = card._tween.get_ref() as Tween
		if tween:
			await wait_for_signal(tween.finished, 0.5)
		else:
			await wait_frames(45)
		assert_eq(deck.get_stack_position(card),card.position,
				"Card moved in, placed in stack position")
		deck.shuffle_cards(false)
		await wait_frames(20)
		assert_eq(deck.get_stack_position(card),card.position,
				"Reshuffle, restacks cards correctly.")

class TestShuffleRng:
	extends "res://tests/Basic_common.gd"

	func test_shuffle_rng():
		var rng_threshold: int = 0
		var card = deck.get_bottom_card()
		var prev_index = card.get_my_card_index()
		deck.shuffle_cards()
		await wait_seconds(1) 
		if prev_index == card.get_my_card_index():
			rng_threshold += 1
		prev_index = card.get_my_card_index()
		deck.shuffle_cards()
		await wait_seconds(1) 
		if prev_index == card.get_my_card_index():
			rng_threshold += 1
		prev_index = card.get_my_card_index()
		deck.shuffle_cards()
		await wait_seconds(1) 
		if prev_index == card.get_my_card_index():
			rng_threshold += 1
		prev_index = card.get_my_card_index()
		assert_gt(2,rng_threshold,
			"Card should not fall in he same spot too many times")
