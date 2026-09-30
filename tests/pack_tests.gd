extends SceneTree

var failures := 0
var game

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, label: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: " + label)

func battle() -> void:
	game.start_run("Hombres Lobo")
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
	battle()
	var pack: Dictionary = game.cards_by_id["L005"]
	check(game._card_cost(pack) == 2, "Coste inicial dos")
	game.energy = 1
	check(not game._can_play(pack), "Sin energía para coste base")
	game.energy = 3
	play("L005")
	check(game.energy == 1 and game.enemy_hp == 88, "Tres golpes y coste base")
	check(game._card_cost(pack) == 1, "Una Manada habilita la siguiente")
	play("L005")
	check(game.energy == 0 and game.enemy_hp == 76, "Segunda Manada rebajada")
	game.enemy_intent_damage = 0
	game._end_turn()
	check(game._card_cost(pack) == 2, "Coste reinicia cada turno")
	battle()
	game.hand.append(pack.duplicate(true))
	play("L002")
	game._refresh_battle()
	await process_frame
	await process_frame
	var displayed := false
	for view in game.hand_box.get_children():
		if view.card_data.id == "L005":
			displayed = true
			check(view.find_child("CostLabel", true, false).text == "1⚡" and not view.disabled, "Coste real visible y carta habilitada")
	check(displayed and pack.coste == 2, "Datos base sin modificar")
	play("L005")
	check(game.energy == 1 and game.enemy_hp == 88, "Aullido y Manada cuestan dos en total")
	battle()
	game.temporary_strength = 2
	game.enemy_block = 5
	play("L005")
	check(game.enemy_hp == 87 and game.enemy_block == 0, "Fuerza por golpe y Bloqueo compartido")
	battle()
	game.player_weak = 1
	game.enemy_vulnerable = 1
	play("L005")
	check(game.enemy_hp == 88, "Débil y Vulnerable redondean cada golpe")
	battle()
	game.enemy_hp = 1
	play("L005")
	check(game.screen == "won", "Manada puede vencer")
	check(not "Manada Feroz · golpe 2" in "\n".join(game.combat_log), "No golpea a enemigo derrotado")
	game.show_rewards()
	game._take_reward("L005")
	check("L005" in game.run_deck, "Recompensa disponible")
	var saved := {"version": 1, "state": "route", "faction": "Hombres Lobo", "stage": 1, "hp": 50, "deck": game.run_deck.duplicate()}
	check(game.save_store.valid(saved, game.cards_by_id, game.STARTER_DECKS, game.REWARDS), "Guardado acepta Manada")
	game._enter_stage()
	check(not game.pack_played and game._card_cost(pack) == 2, "Descuento no pasa a otro combate")
	game.queue_free()
	await process_frame
	print("MANADA: %d fallos" % failures)
	quit(1 if failures else 0)
