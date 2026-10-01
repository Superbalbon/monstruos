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
	game.start_run("Humanos")
	var deck = game.run_deck.duplicate()
	var originals = game.cards_by_id.duplicate(true)
	game._show_catalog()
	var overlay = game.get_node("CatalogOverlay")
	var faction = overlay.find_child("FactionFilter", true, false)
	var version = overlay.find_child("VersionFilter", true, false)
	var search = overlay.find_child("CatalogSearch", true, false)
	var grid = overlay.find_child("CatalogGrid", true, false)
	var count = overlay.find_child("CardCount", true, false)
	version.select(1)
	version.item_selected.emit(1)
	var total := 0
	for index in faction.item_count:
		faction.select(index)
		faction.item_selected.emit(index)
		await process_frame
		await process_frame
		check(grid.get_child_count() == 10, "Diez mejoras por facción")
		check("10 de 10" in count.text and "mejoradas" in count.text, "Contador de mejoras")
		for entry in grid.get_children():
			var view = entry.get_child(0)
			var card = view.card_data
			var expected = game.CardUpgrades.resolve(originals, str(card.id) + "+")
			check(card == expected, "Previsualización completa " + str(card.id))
			check("ACTUAL:" in view.tooltip_text and "MEJORADA:" in view.tooltip_text, "Comparación " + str(card.id))
			check(entry.get_child(1).text == "Mejora en descanso", "Procedencia de mejora")
			check(view.get_global_rect().end.x <= 1280, "Sin recorte horizontal")
			view.pressed.emit()
			total += 1
	check(total == 40, "Cuarenta mejoras consultables")
	search.text = "  POSESION  "
	search.text_changed.emit(search.text)
	check(grid.get_child_count() == 1 and grid.get_child(0).get_child(0).card_data.id == "F002", "Búsqueda sin tildes ni distinción de mayúsculas")
	version.select(0)
	version.item_selected.emit(0)
	check(grid.get_child(0).get_child(0).card_data == originals["F002"], "Cambio a base conserva búsqueda")
	faction.select(0)
	faction.item_selected.emit(0)
	check("0 de 10" in count.text and grid.get_child(0) is Label, "Sin resultados al cambiar facción")
	search.text = ""
	search.text_changed.emit("")
	check(grid.get_child_count() == 10, "Limpiar recupera cartas")
	for entry in grid.get_children():
		var card = entry.get_child(0).card_data
		check(card == originals[card.id], "Base intacta")
	for query in ["bloqueo", "aliado", "comun"]:
		search.text = query
		search.text_changed.emit(query)
		check(grid.get_child(0) is VBoxContainer, "Busca efectos, tipos y rareza: " + query)
	search.text = "milicia"
	search.text_changed.emit(search.text)
	version.select(1)
	version.item_selected.emit(1)
	check("Coste: 2 → 1" in grid.get_child(0).get_child(0).tooltip_text, "Compara reducción de coste")
	check(game.cards_by_id == originals and game.run_deck == deck, "No modifica cartas ni mazo")
	check(game.player_hp == 50 and game.stage == 0 and game.screen == "route", "No modifica expedición")
	overlay.queue_free()
	await process_frame
	game._show_catalog()
	overlay = game.get_node("CatalogOverlay")
	check(overlay.find_child("VersionFilter", true, false).selected == 0, "Reabre en versión base")
	check(overlay.find_child("CatalogSearch", true, false).text.is_empty(), "Reabre sin búsqueda")
	game.queue_free()
	await process_frame
	print("CATÁLOGO MEJORAS: %d fallos" % failures)
	quit(1 if failures else 0)
