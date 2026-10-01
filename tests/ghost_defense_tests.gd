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
	game.start_run("Fantasmas")
	game.stage = 1
	game._enter_stage()
	game.faction_resource = 8

func play(id: String) -> void:
	var card: Dictionary = game.cards_by_id[id].duplicate(true)
	game.hand.append(card)
	game._play_card(card)

func run() -> void:
	root.size = Vector2i(1280, 720)
	game = load("res://main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	battle()
	game.faction_resource = 1
	check(not game._can_play(game.cards_by_id["F002"]), "Posesión requiere recurso")
	game.faction_resource = 8
	play("F002")
	check(game.faction_resource == 6 and game.energy == 2, "Costes Posesión")
	check("2 × 2" in game.intent_label.text, "Posesión actualiza intención")
	check(not game._can_play(game.cards_by_id["F002"]), "Posesión no se acumula")
	game._end_turn()
	check(game.player_hp == 46 and not game.possession_active, "Reduce ambos golpes y caduca")
	check(not game._can_play(game.cards_by_id["F002"]), "No se juega contra defensa")
	battle()
	game.enemy_weak = 1
	play("F002")
	check("1 × 2" in game.intent_label.text, "Débil se calcula antes de Posesión")
	game._end_turn()
	check(game.player_hp == 48, "Daño coincide con intención modificada")
	battle()
	game.faction_resource = 2
	check(not game._can_play(game.cards_by_id["F008"]), "Etéreo requiere recurso")
	game.faction_resource = 8
	play("F008")
	check(game.faction_resource == 5 and game.exhaust_pile.back().id == "F008", "Coste y agotamiento de Paso")
	check(not game._can_play(game.cards_by_id["F008"]), "Etéreo no se acumula")
	game.player_block = 3
	game._end_turn()
	check(game.player_hp == 49 and not game.player_ethereal, "Evita primer golpe y bloquea tres del segundo")
	battle()
	game.enemy_pattern = 1
	game._set_enemy_intent()
	play("F008")
	game._end_turn()
	check(game.player_ethereal, "Defensa enemiga no consume Etéreo")
	game._end_turn()
	check(game.player_hp == 50 and not game.player_ethereal, "Evita siguiente ataque completo de un golpe")
	battle()
	play("F002")
	play("F008")
	game._end_turn()
	check(game.player_hp == 48, "Combinación evita primero y reduce segundo")
	battle()
	check(not game.player_ethereal and not game.possession_active, "Estados reinician")
	game._finish_battle(true)
	game.show_rewards()
	await process_frame
	await process_frame
	var scroll = game.find_children("*", "ScrollContainer", true, false)[0]
	scroll.scroll_horizontal = 10000
	await process_frame
	var row = scroll.get_child(0)
	check(scroll.get_global_rect().encloses(row.get_child(5).get_global_rect()), "Última recompensa accesible al desplazar")
	game.find_child("RewardCard_F008", true, false).pressed.emit()
	check("F008" in game.run_deck, "Paso seleccionable como recompensa")
	var saved := {"version": 1, "state": "route", "faction": "Fantasmas", "stage": 2, "hp": 50, "deck": game.run_deck.duplicate()}
	check(game.save_store.valid(saved, game.cards_by_id, game.STARTER_DECKS, game.REWARDS), "Guardado admite nueva recompensa")
	game.queue_free()
	await process_frame
	print("DEFENSAS FANTASMAS: %d fallos" % failures)
	quit(1 if failures else 0)
