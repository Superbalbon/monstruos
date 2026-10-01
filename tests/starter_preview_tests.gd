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
	var path := "res://.godot/starter-preview-%d.json" % Time.get_ticks_usec()
	game.save_store.path = path
	game.persistence_enabled = true
	game.start_run("Humanos")
	game.player_hp = 29
	game.stage = 2
	game._checkpoint("route")
	var saved := FileAccess.get_file_as_string(path)
	var deck = game.run_deck.duplicate()
	game.show_faction_selection()
	await process_frame
	await process_frame
	for action in game.find_children("*", "Button", true, false):
		check(Rect2(Vector2.ZERO, Vector2(1280, 720)).encloses(action.get_global_rect()), "Acción de selección visible: " + action.text)
	var cancel := InputEventAction.new()
	cancel.action = "ui_cancel"
	cancel.pressed = true
	for index in game.STARTER_DECKS.size():
		var faction: String = game.STARTER_DECKS.keys()[index]
		var button = game.find_child("StarterPreview_" + str(index), true, false)
		check(Rect2(Vector2.ZERO, Vector2(1280, 720)).encloses(button.get_global_rect()), "Botón visible " + faction)
		button.pressed.emit()
		await process_frame
		await process_frame
		var overlay = game.get_node("DeckOverlay")
		var ids: Array[String] = []
		for view in overlay.find_children("*", "Button", true, false):
			if view is CardView:
				ids.append(view.card_data.id)
				check(view.card_data.faccion == faction, "Facción correcta " + view.card_data.id)
				check(view.get_global_rect().end.x <= 1280, "Cartas sin recorte horizontal")
				view.pressed.emit()
		check(ids == game.STARTER_DECKS[faction], "Copias y orden inicial exactos " + faction)
		check("Mejoradas: 0/10" in overlay.find_child("DeckSummary", true, false).text, "Resumen inicial")
		game._request_start_run(faction)
		check(not game.has_node("NewRunConfirmation") and game.screen == "faction", "Consulta no inicia ni confirma partida")
		game._unhandled_key_input(cancel)
		await process_frame
		check(not game.has_node("DeckOverlay") and game.screen == "faction", "Escape vuelve a estirpes")
		check(game.selected_faction == "Humanos" and game.run_deck == deck and game.player_hp == 29 and game.stage == 2, "No modifica expedición actual")
		check(FileAccess.get_file_as_string(path) == saved, "No escribe guardado")
	game._request_start_run("Vampiros")
	check(game.has_node("NewRunConfirmation"), "Jugar conserva confirmación de sustitución")
	game._show_deck("", false, false, "Fantasmas")
	check(not game.has_node("DeckOverlay"), "No abre consulta sobre confirmación")
	game.get_node("NewRunConfirmation").canceled.emit()
	await process_frame
	game._resume_run()
	check(game.screen == "route" and game.player_hp == 29 and game.stage == 2, "Guardado sigue continuable")
	game._show_deck("", false, false, "Humanos")
	check(not game.has_node("DeckOverlay"), "Previsualización limitada a selección")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	game.queue_free()
	await process_frame
	print("MAZOS INICIALES: %d fallos" % failures)
	quit(1 if failures else 0)
