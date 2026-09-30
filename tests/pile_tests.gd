extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, label: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: " + label)

func run() -> void:
	root.size = Vector2i(1280, 720)
	var game = load("res://main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	game.start_run("Humanos")
	game._enter_stage()
	game.draw_pile.assign([game.cards_by_id["H002"], game.cards_by_id["H001"], game.cards_by_id["H001"]])
	game.discard_pile.assign([game.cards_by_id["H003"]])
	game.exhaust_pile.clear()
	game.barricade_active = true
	game._refresh_battle()
	var original_draw = game.draw_pile.duplicate(true)
	var original_hand = game.hand.duplicate(true)
	var original_deck = game.run_deck.duplicate()
	var cancel := InputEventAction.new()
	cancel.action = "ui_cancel"
	cancel.pressed = true
	for pile_name in ["Robo", "Descarte", "Agotadas", "Poderes"]:
		game.pile_buttons[pile_name].pressed.emit()
		await process_frame
		await process_frame
		check(Rect2(Vector2.ZERO, Vector2(1280, 720)).encloses(game.pile_buttons[pile_name].get_global_rect()), "Botón visible " + pile_name)
		var overlay = game.get_node("DeckOverlay")
		var ids: Array[String] = []
		for button in overlay.find_children("*", "Button", true, false):
			if button is CardView:
				ids.append(button.card_data.id)
				button.pressed.emit()
		match pile_name:
			"Robo": check(ids == ["H001", "H001", "H002"], "Orden visual y duplicados de Robo")
			"Descarte": check(ids == ["H003"], "Descarte exacto")
			"Agotadas": check(ids.is_empty(), "Pila vacía")
			"Poderes": check(ids == ["H010"], "Barricada activa visible")
		game._show_deck(pile_name)
		check(game.get_node("DeckOverlay") == overlay, "No duplica visor")
		game._request_menu()
		check(game.screen == "battle", "Consultar no sale de combate")
		game._unhandled_key_input(cancel)
		await process_frame
		check(not game.has_node("DeckOverlay"), "Escape cierra visor")
	check(game.draw_pile == original_draw and game.hand == original_hand and game.run_deck == original_deck, "Consulta no altera orden ni cartas")
	check(game.energy == 3 and game.turn == 1 and game.player_hp == 50, "Consulta no consume turno")
	game.choosing_card = true
	game._show_deck("Robo")
	check(not game.has_node("DeckOverlay"), "No interrumpe Espía")
	game.choosing_card = false
	game.screen = "route"
	game._show_deck("Robo")
	check(not game.has_node("DeckOverlay"), "No muestra pilas antiguas en ruta")
	game._show_deck()
	check(game.has_node("DeckOverlay"), "Mazo completo sigue disponible")
	game.queue_free()
	await process_frame
	print("PILAS: %d fallos" % failures)
	quit(1 if failures else 0)
