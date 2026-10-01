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
	var test_path := "res://.godot/reward-consultation-%d.json" % Time.get_ticks_usec()
	game.save_store.path = test_path
	game.persistence_enabled = true
	var cancel := InputEventAction.new()
	cancel.action = "ui_cancel"
	cancel.pressed = true
	for faction in game.REWARDS:
		game.start_run(faction)
		var id: String = game.REWARDS[faction][0]
		game.run_deck[0] = id
		game.run_deck[1] = id + "+"
		game.screen = "won"
		game.show_rewards()
		await process_frame
		await process_frame
		var saved := FileAccess.get_file_as_string(test_path)
		var original = game.run_deck.duplicate()
		var button = game.find_child("RewardDeckButton", true, false)
		check(Rect2(Vector2.ZERO, Vector2(1280, 720)).encloses(button.get_global_rect()), "Botón visible " + faction)
		for reward_id in game.REWARDS[faction]:
			var owned = game._reward_owned_copies(reward_id)
			check(owned.total == original.count(reward_id) + original.count(reward_id + "+"), "Cuenta copias " + reward_id)
			check(owned.upgraded == original.count(reward_id + "+"), "Cuenta mejoras " + reward_id)
			var label = game.find_child("RewardOwned_" + reward_id, true, false)
			check(label.text == "En tu mazo: %d · Mejoradas: %d" % [owned.total, owned.upgraded], "Etiqueta " + reward_id)
		for control in game.find_children("*", "Button", true, false):
			if not control is CardView:
				check(Rect2(Vector2.ZERO, Vector2(1280, 720)).encloses(control.get_global_rect()), "Acciones dentro de pantalla " + control.text)
		button.pressed.emit()
		check(game.has_node("DeckOverlay"), "Abre mazo")
		check(game.get_node("DeckOverlay").find_child("DeckSummary", true, false) != null, "Incluye resumen")
		game._take_reward(id)
		game._take_reward("")
		game._request_menu()
		check(game.screen == "reward" and game.stage == 0 and game.run_deck == original, "Consulta bloquea elección y salida subyacentes")
		game._unhandled_key_input(cancel)
		await process_frame
		check(not game.has_node("DeckOverlay") and game.screen == "reward", "Escape devuelve a recompensas")
		check(FileAccess.get_file_as_string(test_path) == saved, "Consulta no reescribe guardado")
		# Upgrades are currently obtained after the final reward. Use a legal
		# pre-camp deck for persistence; the mixed deck above tests the counter.
		game.run_deck[1] = id
		original = game.run_deck.duplicate()
		game._checkpoint("reward")
		game._resume_run()
		check(game.screen == "reward" and game.run_deck == original, "Carga mantiene recompensa pendiente")
		game._take_reward(id)
		check(game.run_deck.size() == original.size() + 1 and game.run_deck.back() == id, "Añade una copia base")
		check(game.stage == 1 and game.screen == "route", "Avanza una vez")
		game._take_reward(id)
		check(game.run_deck.size() == original.size() + 1, "No duplica recompensa")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(test_path))
	game.queue_free()
	await process_frame
	print("CONSULTA DE RECOMPENSAS: %d fallos" % failures)
	quit(1 if failures else 0)
