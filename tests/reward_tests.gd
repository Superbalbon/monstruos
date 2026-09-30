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
	root.size = Vector2i(1280, 720)
	game = load("res://main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	for faction in game.REWARDS:
		battle(faction)
		game._finish_battle(true)
		game.show_rewards()
		await process_frame
		await process_frame
		var visible_cards := 0
		for button in game.find_children("*", "Button", true, false):
			if button is CardView:
				visible_cards += 1
				if game.REWARDS[faction].size() <= 4:
					check(Rect2(Vector2.ZERO, Vector2(1280, 720)).encloses(button.get_global_rect()), "Recompensa dentro de pantalla " + button.card_data.id)
		check(visible_cards == game.REWARDS[faction].size(), "Todas las recompensas renderizadas " + faction)
		var scroll = game.find_children("*", "ScrollContainer", true, false)[0]
		scroll.scroll_horizontal = 10000
		await process_frame
		check(scroll.get_global_rect().encloses(scroll.get_child(0).get_children().back().get_global_rect()), "Última recompensa accesible " + faction)
		var id: String = game.REWARDS[faction][3]
		game._take_reward(id)
		check(id in game.run_deck and game.run_deck.size() == 11, "Nueva recompensa " + id)
		var saved := {"version": 1, "state": "route", "faction": faction, "stage": 1, "hp": 50, "deck": game.run_deck.duplicate()}
		check(game.save_store.valid(saved, game.cards_by_id, game.STARTER_DECKS, game.REWARDS), "Guardado admite " + id)
		await process_frame
	battle("Humanos")
	game.player_block = 12
	play("H010")
	check(game.energy == 0 and game.barricade_active, "Coste y activación Barricada")
	check(not game._can_play(game.cards_by_id["H010"]), "Sin energía no se repite Barricada")
	game.enemy_intent_damage = 7
	game._end_turn()
	check(game.player_block == 5 and game.player_hp == 50, "Barricada conserva solo Bloqueo restante")
	check(not game._can_play(game.cards_by_id["H010"]), "No permite duplicar poder activo")
	var in_piles := false
	for pile in [game.hand, game.draw_pile, game.discard_pile, game.exhaust_pile]:
		for card in pile:
			in_piles = in_piles or card.id == "H010"
	check(not in_piles, "Poder activo no vuelve al mazo")
	game.run_deck.append("H010")
	game.start_battle("Humanos")
	check(not game.barricade_active and game.player_block == 0, "Barricada reinicia entre combates")
	check(game.hand.size() + game.draw_pile.size() == 11, "Carta de poder vuelve en próximo combate")
	battle("Hombres Lobo")
	play("L004")
	check(game.enemy_hp == 95 and game.enemy_bleed == 2 and game.faction_resource == 1, "Mordida Rabiosa")
	game.enemy_intent_damage = 0
	game._end_turn()
	check(game.enemy_hp == 93 and game.enemy_bleed == 1, "Sangrado de Mordida")
	battle("Hombres Lobo")
	game.faction_resource = 9
	play("L004")
	check(game.enemy_hp == 95 and game.player_hp == 47 and game.temporary_strength == 2, "Descontrol ocurre después del daño de Mordida")
	battle("Vampiros")
	game.faction_resource = 9
	play("V009")
	check(game.enemy_weak == 2 and game.faction_resource == 10, "Hipnosis aumenta Sed y aplica Débil")
	game.enemy_intent_damage = 10
	game._end_turn()
	check(game.player_hp == 41 and game.player_weak == 1, "Hipnosis reduce ataque pero dispara penalización Sed")
	for ectoplasm in [2, 3]:
		battle("Fantasmas")
		game.faction_resource = ectoplasm
		play("F005")
		check(game.enemy_hp == 93, "Aparición aplica daño antes que Vulnerable")
		check(game.enemy_vulnerable == (1 if ectoplasm == 3 else 0), "Umbral de Aparición")
		check(game.faction_resource == ectoplasm, "Aparición no consume Ectoplasma")
	game.queue_free()
	await process_frame
	print("RECOMPENSAS: %d fallos" % failures)
	quit(1 if failures else 0)
