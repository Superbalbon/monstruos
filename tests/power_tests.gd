extends SceneTree

var failures := 0
var game

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, label: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: " + label)

func battle(faction: String) -> void:
	game.start_run(faction)
	game._enter_stage()
	game.enemy_hp = 100

func play(id: String) -> void:
	var card: Dictionary = game.cards_by_id[id].duplicate(true)
	game.hand.append(card)
	game._play_card(card)

func run() -> void:
	game = load("res://main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	for faction in ["Humanos", "Hombres Lobo", "Vampiros"]:
		battle(faction)
		var id: String = {"Humanos": "H008", "Hombres Lobo": "L007", "Vampiros": "V002"}[faction]
		play(id)
		check(id in game.active_powers, "Poder activo " + id)
		game.energy = 3
		check(not game._can_play(game.cards_by_id[id]), "No duplicar poder " + id)
		for pile in [game.hand, game.draw_pile, game.discard_pile, game.exhaust_pile]:
			for card in pile:
				check(card.id != id, "Poder fuera de pilas " + id)
		game._show_deck("Poderes")
		var overlay = game.get_node("DeckOverlay")
		var cards: Array = overlay.find_children("*", "Button", true, false).filter(func(button): return button is CardView)
		check(cards.size() == 1 and cards[0].card_data.id == id, "Visor muestra el poder correcto")
		var close_buttons: Array = overlay.find_children("*", "Button", true, false).filter(func(button): return button.text == "VOLVER AL COMBATE")
		check(close_buttons.size() == 1, "Visor permite volver al combate")
		var before := JSON.stringify([game.active_powers, game.energy, game.hand])
		cards[0].find_child("InspectCard", true, false).pressed.emit()
		check(root.has_node("CardDetail"), "Poder permite ampliar ilustración y reglas")
		root.get_node("CardDetail").confirmed.emit()
		await process_frame
		check(before == JSON.stringify([game.active_powers, game.energy, game.hand]), "Consultar poder no vuelve a activarlo")
		game.run_deck.append(id)
		game.start_battle(faction)
		check(game.active_powers.is_empty() and game.hand.size() + game.draw_pile.size() == 11, "Poder vuelve al mazo y reinicia")
		await process_frame
	battle("Humanos")
	play("H008")
	game.hand.clear()
	play("H004")
	check(game.hand.size() == 1 and game.hunter_triggered, "Cazador roba al aplicar Vulnerable")
	play("H004")
	check(game.hand.size() == 1, "Cazador una vez por turno")
	game.enemy_intent_damage = 0
	game._end_turn()
	var hand_size: int = game.hand.size()
	play("H004")
	check(game.hand.size() == hand_size + 1, "Cazador vuelve a activarse el siguiente turno")
	battle("Vampiros")
	play("V002")
	check(game.player_block == 3, "Niebla Eterna cuenta su propia etiqueta")
	play("V007")
	check(game.player_block == 8, "Sin segundo bonus de Niebla")
	game.enemy_intent_damage = 0
	game._end_turn()
	play("V007")
	check(game.player_block == 8, "Bonus Niebla se renueva")
	play("V007")
	check(game.player_block == 13, "Solo un bonus por turno")
	battle("Hombres Lobo")
	play("L007")
	check(game.faction_resource == 0 and game.temporary_strength == 0, "Luna no activa al jugar")
	game.enemy_intent_damage = 0
	game._end_turn()
	check(game.faction_resource == 1 and game.temporary_strength == 1, "Luna al iniciar turno")
	play("L001")
	check(game.enemy_hp == 93, "Fuerza lunar aplicada")
	game.faction_resource = 9
	game.enemy_intent_damage = 0
	game._end_turn()
	check(game.faction_resource == 5 and game.temporary_strength == 3 and game.player_hp == 47, "Luna dispara Descontrol")
	game.faction_resource = 9
	game.player_hp = 3
	game.enemy_intent_damage = 0
	game._end_turn()
	check(game.screen == "lost" and "DERROTA" in game.message_label.text, "Derrota por Luna no queda oculta")
	game.queue_free()
	await process_frame
	print("PODERES: %d fallos" % failures)
	quit(1 if failures else 0)
