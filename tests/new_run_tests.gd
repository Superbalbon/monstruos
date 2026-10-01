extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, label: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: " + label)

func run() -> void:
	var game = load("res://main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	var path := "res://.godot/new-run-test-%d.json" % Time.get_ticks_usec()
	game.save_store.path = path
	game.persistence_enabled = true
	game.show_faction_selection()
	game._request_start_run("Humanos")
	check(game.screen == "route" and not game.has_node("NewRunConfirmation"), "Primer inicio directo")
	for state in ["route", "reward"]:
		game._checkpoint(state)
		var before := FileAccess.get_file_as_string(path)
		var deck = game.run_deck.duplicate()
		game.show_faction_selection()
		game._request_start_run("Vampiros")
		var dialog = game.get_node("NewRunConfirmation")
		check("Humanos" in dialog.dialog_text and "Vampiros" in dialog.dialog_text, "Identifica partida antigua y nueva")
		check(("recompensa pendiente" in dialog.dialog_text) == (state == "reward"), "Indica recompensa pendiente")
		check(dialog.get_cancel_button().has_focus(), "Opción conservadora por defecto")
		game._request_start_run("Fantasmas")
		check(game.get_node("NewRunConfirmation") == dialog, "No duplica diálogo")
		dialog.canceled.emit()
		await process_frame
		check(game.screen == "faction" and game.run_deck == deck, "Cancelar no inicia partida")
		check(FileAccess.get_file_as_string(path) == before, "Cancelar no escribe guardado")
		game._request_start_run("Vampiros")
		var cancel := InputEventAction.new()
		cancel.action = "ui_cancel"
		cancel.pressed = true
		game._unhandled_key_input(cancel)
		await process_frame
		check(not game.has_node("NewRunConfirmation") and game.screen == "faction", "Escape cierra confirmación")
		game._unhandled_key_input(cancel)
		check(game.screen == "title", "Segundo Escape vuelve al menú")
		check(FileAccess.get_file_as_string(path) == before, "Escape conserva archivo")
		game._resume_run()
		check(game.selected_faction == "Humanos" and game.screen == state, "Partida antigua sigue continuable")
	game.show_faction_selection()
	game._request_start_run("Vampiros")
	game.get_node("NewRunConfirmation").confirmed.emit()
	var saved = game.save_store.read(game.cards_by_id, game.STARTER_DECKS, game.REWARDS)
	check(game.screen == "route" and saved.faction == "Vampiros" and saved.stage == 0 and saved.hp == 50, "Confirmar sustituye por nueva expedición")
	game._checkpoint("finished")
	game.show_faction_selection()
	game._request_start_run("Fantasmas")
	check(game.screen == "route" and not game.has_node("NewRunConfirmation"), "Finalizada no requiere confirmación")
	# Valid JSON with an unsupported version models an incompatible save.
	game.save_store.write({"version": 999})
	var invalid_before := FileAccess.get_file_as_string(path)
	game.show_faction_selection()
	game._request_start_run("Humanos")
	check("incompatible" in game.get_node("NewRunConfirmation").dialog_text, "Protege guardado incompatible")
	game.get_node("NewRunConfirmation").canceled.emit()
	await process_frame
	check(FileAccess.get_file_as_string(path) == invalid_before, "No altera archivo incompatible al cancelar")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	game.queue_free()
	await process_frame
	print("NUEVA EXPEDICIÓN: %d fallos" % failures)
	quit(1 if failures else 0)
