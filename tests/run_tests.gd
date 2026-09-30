extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: " + message)

func run() -> void:
	var game = load("res://main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	for faction in game.STARTER_DECKS:
		game.start_run(faction)
		check(game.run_deck.size() == 10 and game.player_hp == 50, "Nueva partida " + faction)
		game._enter_stage()
		check(game.hand.size() == 5 and game.draw_pile.size() == 5, "Robo inicial")
		game.player_hp = 31
		game.enemy_hp = 0
		game._finish_battle(true)
		game.show_rewards()
		var reward: String = game.REWARDS[faction][0]
		game._take_reward(reward)
		game._take_reward(reward)
		check(game.run_deck.size() == 11 and game.stage == 1, "Recompensa única")
		game._rest(12)
		check(game.player_hp == 43 and game.stage == 2, "Refugio")
		game._enter_stage()
		check(game.player_hp == 43 and game.hand.size() + game.draw_pile.size() == 11, "Persistencia")
		for id in game.REWARDS[faction]:
			game.hand.clear()
			var card: Dictionary = game.cards_by_id[id].duplicate(true)
			game.hand.append(card)
			game.energy = 3
			game.enemy_hp = 100
			game.player_hp = 30
			game.enemy_weak = 0
			game.enemy_bleed = 0
			game.faction_resource = 3
			var expected_cost: int = game._card_cost(card)
			game._play_card(card)
			check(game.energy == 3 - expected_cost, "Coste " + id)
			match id:
				"H004": check(game.enemy_hp == 97 and game.enemy_vulnerable == 2, id)
				"H005": check(game.enemy_weak == 1, id)
				"L006": check(game.enemy_hp == 96 and game.enemy_bleed == 2 and game.faction_resource == 1, id)
				"L008": check(game.enemy_hp == 92, id)
				"V005": check(game.enemy_hp == 90 and game.player_hp == 33 and game.faction_resource == 1, id)
				"V006": check(game.enemy_hp == 92 and game.faction_resource == 4, id)
				"F004": check(game.enemy_hp == 96 and game.faction_resource == 4, id)
				"F006": check(game.enemy_weak == 2 and game.faction_resource == 4, id)
			game.enemy_vulnerable = 0
		game.enemy_hp = 0
		game._finish_battle(true)
		game.show_rewards()
		game._take_reward("")
		check(game.stage == 3 and game.run_deck.size() == 11, "Rechazar recompensa")
		game._enter_stage()
		check(game.stage == 4 and game.player_hp <= 50, "Descanso limitado")
		game._enter_stage()
		check(game.enemy_hp == 58 and game.encounter_name == "EL CUSTODIO", "Jefe")
		game.enemy_hp = 0
		game._finish_battle(true)
		check(game.end_turn_button.text == "VOLVER A ELEGIR ESTIRPE", "Final de ruta")
		await process_frame
	# Two equal dictionaries must remain two physical cards after scouting.
	game.start_run("Vampiros")
	game._enter_stage()
	game.hand.clear()
	game.draw_pile.clear()
	game.discard_pile.clear()
	var choices: Array[Dictionary] = [game.cards_by_id["V001"].duplicate(true), game.cards_by_id["V001"].duplicate(true)]
	var overlay := ColorRect.new()
	game.add_child(overlay)
	game.choosing_card = true
	game._resolve_scout(0, choices, overlay)
	check(game.hand.size() == 1 and game.draw_pile.size() == 1, "Espía con duplicados")
	game.player_hp = 1
	game.player_block = 0
	game.enemy_intent_damage = 13
	game._end_turn()
	check(game.screen == "lost", "Derrota")
	game.start_run("Humanos")
	check(game.player_hp == 50 and game.stage == 0 and game.run_deck.size() == 10, "Reinicio limpio")
	game.queue_free()
	await process_frame
	print("RESULTADO: %d fallos" % failures)
	quit(1 if failures else 0)
