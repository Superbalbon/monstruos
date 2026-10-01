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
	var path := "res://.godot/epilogue-%d.json" % Time.get_ticks_usec()
	game.save_store.path = path
	game.persistence_enabled = true
	var stories: Array[String] = []
	for faction in game.STARTER_DECKS:
		game.start_run(faction)
		game.stage = 4
		game._enter_stage()
		game.enemy_hp = 0
		game._finish_battle(true)
		await process_frame
		await process_frame
		var button = game.find_child("EpilogueButton", true, false)
		check(button != null and Rect2(Vector2.ZERO, Vector2(1280, 720)).encloses(button.get_global_rect()), "Acceso visible " + faction)
		var saved := FileAccess.get_file_as_string(path)
		var deck = game.run_deck.duplicate()
		var history = game.combat_log.duplicate()
		button.pressed.emit()
		var overlay = game.get_node("DeckOverlay")
		var story: String = overlay.find_child("EpilogueStory", true, false).text
		check(not story.is_empty() and story not in stories, "Epílogo único " + faction)
		stories.append(story)
		game._show_epilogue()
		check(game.get_node("DeckOverlay") == overlay, "No duplica epílogo")
		await process_frame
		await process_frame
		check(Rect2(Vector2.ZERO, Vector2(1280, 720)).encloses(overlay.find_child("CloseEpilogue", true, false).get_global_rect()), "Cierre visible")
		var cancel := InputEventAction.new()
		cancel.action = "ui_cancel"
		cancel.pressed = true
		game._unhandled_key_input(cancel)
		await process_frame
		check(not game.has_node("DeckOverlay") and game.screen == "won", "Escape vuelve al resultado")
		check(game.run_deck == deck and game.combat_log == history and FileAccess.get_file_as_string(path) == saved, "Lectura sin efectos ni escrituras")
		game._show_epilogue()
		game.get_node("DeckOverlay").find_child("CloseEpilogue", true, false).pressed.emit()
		await process_frame
		check(not game.has_node("DeckOverlay"), "Botón cierra tras releer")
		game._resume_run()
		check(game.screen == "title", "Victoria sigue finalizada")
	game.start_run("Humanos")
	game._enter_stage()
	game._finish_battle(true)
	game._show_epilogue()
	check(not game.has_node("DeckOverlay") and game.find_child("EpilogueButton", true, false) == null, "No aparece en victoria intermedia")
	game.start_run("Humanos")
	game.stage = 4
	game._enter_stage()
	game.player_hp = 0
	game._finish_battle(false)
	game._show_epilogue()
	check(not game.has_node("DeckOverlay") and game.find_child("EpilogueButton", true, false) == null, "No aparece en derrota")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	game.queue_free()
	await process_frame
	print("EPÍLOGOS: %d fallos" % failures)
	quit(1 if failures else 0)
