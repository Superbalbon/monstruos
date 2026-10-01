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
	var scene = load("res://main.tscn")
	var game = scene.instantiate()
	var other = scene.instantiate()
	var path := "res://.godot/upgrade-test-%d.json" % Time.get_ticks_usec()
	for instance in [game, other]:
		instance.persistence_enabled = false
		root.add_child(instance)
		instance.save_store.path = path
		instance.persistence_enabled = true
	var cancel := InputEventAction.new()
	cancel.action = "ui_cancel"
	cancel.pressed = true
	for id in ["H001", "H003", "L001", "L029", "V001", "V007", "F009", "F003"]:
		var base: Dictionary = game.cards_by_id[id].duplicate(true)
		game.start_run(base.faccion)
		game._show_deck("", false, true)
		check(not game.has_node("DeckOverlay"), "Mejora solo en descanso")
		game.stage = 3
		game.player_hp = 22
		game.show_route()
		var before: Array = game.run_deck.duplicate()
		var index: int = game.run_deck.find(id)
		game._show_deck("", false, true)
		await process_frame
		await process_frame
		var views = game.get_node("DeckOverlay").find_children("*", "Button", true, false)
		check(views[index].card_data.upgraded and "DESPUÉS" in views[index].tooltip_text, "Vista previa " + id)
		check(game.run_deck == before, "Previsualizar no modifica mazo")
		game._unhandled_key_input(cancel)
		await process_frame
		check(game.stage == 3 and game.run_deck == before, "Cancelar conserva descanso")
		game._show_deck("", false, true)
		game._upgrade_card_at_camp(-1)
		game._upgrade_card_at_camp(100)
		game._upgrade_card_at_camp(index)
		check(game.player_hp == 22 and game.stage == 4 and game.run_deck.size() == 10, "Mejora sin curar ni retirar")
		check(game.run_deck[index] == id + "+" and game.run_deck.count(id) == before.count(id) - 1, "Mejora solo una copia " + id)
		game._upgrade_card_at_camp(index)
		game._rest(15)
		check(game.player_hp == 22 and game.run_deck[index] == id + "+", "No repetir descanso")
		var saved: Dictionary = game.save_store.read(game.cards_by_id, game.STARTER_DECKS, game.REWARDS)
		check(not saved.is_empty() and saved.version == 2, "Versión nueva para mejoras")
		other._resume_run()
		check(other.run_deck == game.run_deck and other.player_hp == 22 and other.stage == 4, "Carga copia mejorada")
		other._enter_stage()
		var all_cards: Array = other.hand + other.draw_pile
		var improved: Dictionary = {}
		var count := 0
		for card in all_cards:
			if card.get("upgraded", false):
				improved = card
				count += 1
		check(count == 1 and improved.id == id, "Combate contiene una mejora")
		check(other._card_art_path(improved) == other._card_art_path(base), "Reutiliza ilustración base")
		other.hand.clear()
		other.hand.append(improved)
		other._play_card(improved)
		if base.tipo == "Ataque":
			check(other.enemy_hp == 58 - game.CardUpgrades.VALUES[id].attack_damage, "Daño mejorado " + id)
		else:
			check(other.player_block == 8, "Bloqueo mejorado " + id)
		check(other.discard_pile.back().get("upgraded", false), "Mejora sigue en descarte")
		check(game.cards_by_id[id] == base, "No cambia definición base")
		for change in [{"version": 1}, {"stage": 2}]:
			var invalid := saved.duplicate(true)
			invalid.merge(change, true)
			check(not game.save_store.valid(invalid, game.cards_by_id, game.STARTER_DECKS, game.REWARDS), "Rechaza mejora incompatible")
		var invalid := saved.duplicate(true)
		invalid.deck[index] = id + "++"
		check(not game.save_store.valid(invalid, game.cards_by_id, game.STARTER_DECKS, game.REWARDS), "Rechaza doble sufijo")
	game.persistence_enabled = false
	game.start_run("Fantasmas")
	game._enter_stage()
	game.enemy_hp = 100
	game.faction_resource = 4
	var improved: Dictionary = game.CardUpgrades.resolve(game.cards_by_id, "F009+")
	game.hand.append(improved)
	game._play_card(improved)
	var echo: Dictionary = game.cards_by_id["F015"].duplicate(true)
	game.hand.append(echo)
	game._play_card(echo)
	check(game.enemy_hp == 87, "Eco conserva daño de ataque mejorado: nueve más cuatro")
	check(game.CardUpgrades.resolve(game.cards_by_id, "INVALID+").is_empty(), "No admite carta desconocida")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	game.queue_free()
	other.queue_free()
	await process_frame
	print("MEJORAS: %d fallos" % failures)
	quit(1 if failures else 0)
