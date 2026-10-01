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
	var card: Dictionary = game.CardUpgrades.resolve(game.cards_by_id, id)
	game.hand.append(card)
	game._play_card(card)

func run() -> void:
	game = load("res://main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	var path := "res://.godot/special-upgrade-%d.json" % Time.get_ticks_usec()
	game.save_store.path = path
	for id in game.cards_by_id:
		var card: Dictionary = game.cards_by_id[id]
		check(game.CardUpgrades.can_upgrade(id), "Toda carta tiene mejora " + id)
		game.start_run(card.faccion)
		game.stage = 3
		if id not in game.run_deck:
			game.run_deck.append(id)
		game.show_route()
		game._show_deck("", false, true)
		game._upgrade_card_at_camp(game.run_deck.find(id))
		check(id + "+" in game.run_deck, "Mejora accesible " + id)
		game.persistence_enabled = true
		game._checkpoint("route")
		var saved: Dictionary = game.save_store.read(game.cards_by_id, game.STARTER_DECKS, game.REWARDS)
		check(not saved.is_empty() and saved.deck == game.run_deck, "Guardado de mejora " + id)
		game.persistence_enabled = false
		await process_frame
	battle("Humanos")
	play("H006+")
	check(game.energy == 2 and game.allies.back().upgraded, "Milicia cuesta uno y permanece mejorada")
	play("H009+")
	check(game.player_block == 12 and game.allies.size() == 2, "Héroe mejorado da doce Bloqueo")
	battle("Humanos")
	play("H010+")
	check(game.energy == 1 and game.barricade_active, "Barricada cuesta dos")
	game._show_deck("Poderes")
	check(game.get_node("DeckOverlay").find_children("*", "Button", true, false)[0].card_data.upgraded, "Pilas muestran poder mejorado")
	game.start_run("Humanos")
	game.run_deck[0] = "H008+"
	for repeat in 8:
		game.start_battle("Humanos")
		check(game.hand.any(func(card): return card.id == "H008" and card.get("upgraded", false)) and game.hand.size() == 5, "Cazador innato en mano de cinco")
	battle("Hombres Lobo")
	play("L003+")
	check(game.energy == 2 and "L003" in game.active_powers, "Alfa cuesta uno")
	battle("Hombres Lobo")
	game.faction_resource = 8
	play("L007+")
	check(game.player_hp == 47 and game.faction_resource == 5 and game.temporary_strength == 2, "Luna activa Descontrol al entrar")
	game.enemy_intent_damage = 0
	game._end_turn()
	check(game.faction_resource == 6 and game.temporary_strength == 1, "Luna conserva efecto recurrente")
	battle("Hombres Lobo")
	play("L018+")
	check(game.exhaust_pile.is_empty() and game.discard_pile.back().id == "L018", "Pista mejorada no se agota")
	battle("Vampiros")
	play("V002+")
	check(game.player_block == 5, "Niebla mejorada da cinco al entrar")
	play("V007")
	check(game.player_block == 10, "Niebla se activa una vez por turno")
	game.enemy_intent_damage = 0
	game._end_turn()
	play("V007")
	check(game.player_block == 10, "Niebla mejorada persiste al siguiente turno")
	battle("Vampiros")
	play("V003+")
	play("V006")
	check(game.energy == 2 and game.thirst_energy_used, "Sed devuelve un Ímpetu en primera activación")
	game.enemy_intent_damage = 0
	game._end_turn()
	play("V006")
	check(game.energy == 2, "Sed no devuelve Ímpetu en otro turno")
	game.start_battle("Vampiros")
	check(not game.thirst_energy_used and game.power_cards.is_empty(), "Bonificación y poderes reinician")
	battle("Vampiros")
	game.draw_pile.clear()
	game.discard_pile.clear()
	for id in ["V001", "V007", "V014"]:
		game.draw_pile.append(game.cards_by_id[id].duplicate(true))
	play("V004+")
	var options = game.get_node("ScoutOverlay").find_children("*", "Button", true, false)
	check(options.size() == 3, "Espía permite elegir entre tres")
	options[1].pressed.emit()
	check(game.hand.back().id == "V007" and game.draw_pile.back().id == "V014" and game.draw_pile[0].id == "V001", "Espía devuelve las otras dos en orden")
	battle("Vampiros")
	game.last_enemy_card = game._enemy_action_card()
	play("V008+")
	check(game.hand.back().temporal and game.hand.back().coste == 0, "Conversión crea copia gratuita temporal")
	battle("Fantasmas")
	game.faction_resource = 1
	check(game._can_play(game.CardUpgrades.resolve(game.cards_by_id, "F002+")), "Posesión acepta recurso reducido")
	play("F002+")
	check(game.faction_resource == 0 and game.possession_active, "Posesión gasta uno")
	game.faction_resource = 2
	play("F008+")
	check(game.faction_resource == 0 and game.player_ethereal, "Paso gasta dos")
	battle("Fantasmas")
	play("F007+")
	check(game.energy == 2 and game.enemy_weak == 2 and game.faction_resource == 2, "Lamento cuesta uno")
	play("F009")
	play("F015+")
	check(game.enemy_hp == 90 and game.faction_resource == 0, "Eco repite seis al 75 por ciento redondeado a cuatro")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	game.queue_free()
	await process_frame
	print("MEJORAS ESPECIALES: %d fallos" % failures)
	quit(1 if failures else 0)
