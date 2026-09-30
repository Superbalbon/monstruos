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
	game._show_catalog()
	game._show_catalog()
	check(game.screen == "title" and game.run_deck.is_empty(), "Consultar sin iniciar expedición")
	var overlay = game.get_node("CatalogOverlay")
	var filter = overlay.find_child("FactionFilter", true, false)
	var grid = overlay.find_child("CatalogGrid", true, false)
	for index in filter.item_count:
		filter.select(index)
		filter.item_selected.emit(index)
		await process_frame
		await process_frame
		var faction: String = filter.get_item_text(index)
		var found: Array[String] = []
		for entry in grid.get_children():
			var card = entry.get_child(0)
			var id: String = card.card_data.id
			check(id not in found, "Sin duplicados " + id)
			found.append(id)
			check(card.card_data.faccion == faction, "Filtro por facción " + id)
			check(card.get_global_rect().end.x <= 1280, "Sin recorte horizontal " + id)
			var expected := "Inicial + recompensa" if id in game.STARTER_DECKS[faction] and id in game.REWARDS[faction] else ("Mazo inicial" if id in game.STARTER_DECKS[faction] else "Solo recompensa")
			check(entry.get_child(1).text == expected, "Origen " + id)
		for id in game.STARTER_DECKS[faction] + game.REWARDS[faction]:
			check(id in found, "Incluye carta jugable " + id)
	var cancel := InputEventAction.new()
	cancel.action = "ui_cancel"
	cancel.pressed = true
	game._unhandled_key_input(cancel)
	await process_frame
	check(not game.has_node("CatalogOverlay") and game.screen == "title", "Escape vuelve al menú")
	game.start_run("Vampiros")
	var deck = game.run_deck.duplicate()
	game._show_catalog()
	filter = game.get_node("CatalogOverlay").find_child("FactionFilter", true, false)
	check(filter.get_item_text(filter.selected) == "Vampiros", "Abre en facción actual")
	game._request_menu()
	check(game.screen == "route", "Catálogo bloquea salida subyacente")
	game._unhandled_key_input(cancel)
	await process_frame
	check(game.screen == "route" and game.run_deck == deck and game.player_hp == 50 and game.stage == 0, "Consulta conserva expedición")
	game.queue_free()
	await process_frame
	print("CATÁLOGO: %d fallos" % failures)
	quit(1 if failures else 0)
