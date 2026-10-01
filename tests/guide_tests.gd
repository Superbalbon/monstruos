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
	game._show_rules()
	game._show_rules()
	check(game.find_children("RulesOverlay", "", false, false).size() == 1, "No duplica guía")
	var guide = game.get_node("RulesOverlay")
	var topics = guide.find_child("GuideTopics", true, false)
	var body = guide.find_child("GuideBody", true, false)
	check(topics.item_count == 7, "Siete temas disponibles")
	for index in topics.item_count:
		topics.select(index)
		topics.item_selected.emit(index)
		await process_frame
		await process_frame
		check(body.text == guide.SECTIONS[topics.get_item_text(index)], "Contenido del tema " + str(index))
		check(Rect2(Vector2.ZERO, Vector2(1280, 720)).encloses(body.get_global_rect()), "Texto dentro de pantalla")
	check(game.screen == "title" and game.run_deck.is_empty(), "Guía no inicia partida")
	var cancel := InputEventAction.new()
	cancel.action = "ui_cancel"
	cancel.pressed = true
	game._unhandled_key_input(cancel)
	await process_frame
	check(not game.has_node("RulesOverlay"), "Esc cierra guía")
	game.start_run("Humanos")
	game._enter_stage()
	var before := [game.player_hp, game.energy, game.turn, game.hand.duplicate(true), game.draw_pile.duplicate(true), game.run_deck.duplicate(), game.combat_log.duplicate()]
	game.end_turn_button.grab_focus()
	game._show_rules()
	guide = game.get_node("RulesOverlay")
	check(game.get_viewport().gui_get_focus_owner() == guide.find_child("CloseGuide", true, false), "Foco no permanece en Terminar turno")
	game._request_menu()
	game._show_deck()
	game._show_catalog()
	game._show_history()
	check(not game.has_node("MenuConfirmation") and not game.has_node("DeckOverlay") and not game.has_node("CatalogOverlay"), "No abre otras ventanas detrás de la guía")
	guide.find_child("CloseGuide", true, false).pressed.emit()
	await process_frame
	check(game.get_viewport().gui_get_focus_owner() == game.end_turn_button, "Restaura foco")
	check(before == [game.player_hp, game.energy, game.turn, game.hand, game.draw_pile, game.run_deck, game.combat_log], "Consulta conserva todo el combate")
	check(game.screen == "battle", "Vuelve al combate")
	game.choosing_card = true
	game._show_rules()
	check(not game.has_node("RulesOverlay"), "No interrumpe selección del Espía")
	game.queue_free()
	await process_frame
	print("GUÍA: %d fallos" % failures)
	quit(1 if failures else 0)
