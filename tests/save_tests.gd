extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, label: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: " + label)

func run() -> void:
	var scene = load("res://main.tscn")
	var game = scene.instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	var other = scene.instantiate()
	other.persistence_enabled = false
	root.add_child(other)
	var test_path := "res://.godot/save-test-%d.json" % Time.get_ticks_usec()
	game.save_store.path = test_path
	other.save_store.path = test_path
	game.persistence_enabled = true
	other.persistence_enabled = true
	for faction in game.STARTER_DECKS:
		game.start_run(faction)
		other._resume_run()
		check(other.selected_faction == faction and other.screen == "route", "Carga independiente " + faction)
		game._enter_stage()
		game.player_hp = 23
		other._resume_run()
		check(other.player_hp == 50 and other.stage == 0, "Interrupción de combate")
		game.enemy_hp = 0
		game._finish_battle(true)
		other._resume_run()
		check(other.screen == "reward" and other.player_hp == 23, "Recompensa pendiente")
		other._take_reward(str(other.REWARDS[faction][0]))
		game._resume_run()
		check(game.run_deck.size() == 11 and game.stage == 1, "Recompensa persistida")
		game._rest(12)
		other._resume_run()
		other._rest(12)
		check(other.player_hp == 35 and other.stage == 2, "Descanso no repetible")
		other._show_deck()
		await process_frame
		check(other.has_node("DeckOverlay"), "Visor de mazo")
		other._enter_stage()
		other._finish_battle(false)
		game._resume_run()
		check(game.screen == "title", "Derrota no continuable")
	# Invalid files must not mutate a live run.
	game.start_run("Humanos")
	var valid: Dictionary = game.save_store.read(game.cards_by_id, game.STARTER_DECKS, game.REWARDS)
	for change in [{"version": 999}, {"hp": -1}, {"hp": "bad"}, {"stage": 2.5}, {"faction": "unknown"}, {"deck": ["missing"]}, {"state": "battle"}]:
		var invalid := valid.duplicate(true)
		invalid.merge(change, true)
		check(not game.save_store.valid(invalid, game.cards_by_id, game.STARTER_DECKS, game.REWARDS), "Validación " + str(change))
	var file := FileAccess.open(test_path, FileAccess.WRITE)
	file.store_string("{broken")
	file.close()
	check(game.save_store.read(game.cards_by_id, game.STARTER_DECKS, game.REWARDS).is_empty(), "JSON dañado")
	check(not game.save_store.last_error.is_empty(), "Error visible")
	game.save_store.path = "res://.godot/nonexistent-save-parent/test.json"
	check(not game.save_store.write(valid), "Error de escritura")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(test_path))
	game.queue_free()
	other.queue_free()
	await process_frame
	print("GUARDADO: %d fallos" % failures)
	quit(1 if failures else 0)
